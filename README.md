# palo-alto-azure

Terraform configuration that deploys a dual-region, hub-and-spoke Azure
network protected by Palo Alto Networks VM-Series firewalls:

- **UK South** as the primary region (`prod` by default).
- **UK West** as the disaster-recovery (DR) region (`dr` by default).

Each region gets its own hub VNet (with the firewall's management, untrust,
and trust subnets, plus a `GatewaySubnet`), two spoke VNets (`app1`,
`app2`), a VM-Series firewall pair of load balancers, NSGs, default routes
through the firewall, and Log Analytics-based monitoring. The two hubs are
peered to each other for inter-region connectivity; each hub is also peered
to its own spokes.

## Architecture

```
                 Internet
                    │
        ┌───────────┴───────────┐
        │   Public Load Balancer │  (Standard SKU, HTTPS rule)
        └───────────┬───────────┘
                     │
             ┌───────▼────────┐        Untrust subnet (Palo-Untrust)
             │  VM-Series FW   │◄────── NSG: allow-all inbound (FW enforces policy)
             │  (3 NICs)       │
             └───┬────────┬───┘
        Mgmt NIC │        │ Trust NIC        Trust subnet (Palo-Trust)
   (opt-in       │        │
    public IP)   │   ┌────▼─────────────┐
                 │   │ Internal LB (HA   │
   Mgmt subnet   │   │ Ports, all proto) │
  (NSG: allow    │   └────┬──────────────┘
   only from     │        │
mgmt_allowed_    │   ┌────▼─────┐   ┌──────────┐
   cidrs)        │   │ Spoke:   │   │ Spoke:   │
                 │   │ app1     │   │ app2     │
                 │   └──────────┘   └──────────┘
                 │   Route table: 0.0.0.0/0 → firewall trust IP
                 ▼
        Log Analytics workspace
     (diagnostic settings: FW VM,
      public LB, internal LB)
```

The same topology is duplicated in UK West for DR. The two hub VNets are
peered together (`peering.tf`); gateway transit / remote gateways on that
peering are both off by default (`hub_peering_allow_gateway_transit`,
`hub_peering_use_remote_gateways`) and can be enabled if a VPN/ExpressRoute
gateway is later added to `GatewaySubnet`.

### Firewall NICs

Each VM-Series firewall has three NICs, in this order (order matters for
PAN-OS boot):

1. **Management** — out-of-band, always gets a private IP; a public IP is
   attached only when `enable_mgmt_public_ip = true` (default `false` —
   reach management via VPN/Bastion/private connectivity instead).
2. **Untrust** (`ethernet1/1`) — behind the public Standard Load Balancer,
   accelerated networking + IP forwarding on.
3. **Trust** (`ethernet1/2`) — behind the internal Standard Load Balancer
   (HA Ports rule, all protocols/ports), accelerated networking + IP
   forwarding on.

Firewalls authenticate with an SSH public key (`admin_ssh_public_key`), not
a password.

### Security groups

- **Mgmt NSG**: allows HTTPS (443), SSH (22), and Panorama (3978) only from
  `mgmt_allowed_cidrs`, denies everything else inbound. `mgmt_allowed_cidrs`
  must be non-empty and cannot include `0.0.0.0/0` (enforced by variable
  validation).
- **Untrust NSG**: allows all inbound — the firewall itself enforces
  security policy on this interface, not the NSG.

These are the security posture decisions made for this repo; see the
sibling issues on NSGs, SSH keys, and the management public IP for the
reasoning — this README documents the resulting behavior rather than
re-litigating those decisions.

### Tagging

Every resource is tagged via `local.uks_tags` or `local.ukw_tags`
(`locals.tf`), each of which sets `Environment` to the correct region's
`environment` value (`primary_region.environment` for UK South,
`secondary_region.environment` for UK West) so DR resources are correctly
tagged (e.g. `dr`) instead of inheriting the primary region's tag.

### Remote state

State is stored remotely in Azure Storage via a partial `azurerm` backend
configuration (`versions.tf`). See [`docs/backend.md`](docs/backend.md) for
one-time bootstrap steps (creating the storage account/container and a
local, gitignored `backend.hcl`) before running `terraform init`.

## Prerequisites

- An Azure subscription and an account/service principal with permission to
  create resource groups, networking, VMs, and (for the backend) a storage
  account.
- **PAN-OS marketplace agreement.** The VM-Series image is a marketplace
  image; the subscription must accept its terms before the firewall VMs can
  be created. `firewall.tf` includes a commented-out
  `azurerm_marketplace_agreement` resource:

  ```hcl
  # resource "azurerm_marketplace_agreement" "paloalto" {
  #   publisher = var.panos_image.publisher
  #   offer     = var.panos_image.offer
  #   plan      = var.panos_image.sku
  # }
  ```

  Uncomment it, run `terraform apply -target=azurerm_marketplace_agreement.paloalto`
  once per subscription, then comment it back out (or accept the agreement
  via `az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol`)
  before applying the rest of the configuration.
- Terraform `>= 1.5.0` (developed and validated against 1.14.x; CI pins a
  specific version — see below).
- An SSH key pair for firewall administration (`admin_ssh_public_key`).

## Inputs

All variables live in `variables.tf` and have sensible defaults for a
first deployment; override what you need in `terraform.tfvars` (copy
`terraform.tfvars.example` as a starting point). Every variable below has a
`validation` block that fails fast at `plan` time on malformed input
(bad CIDRs, invalid IPs, empty region codes, a non-key-shaped
`admin_ssh_public_key`, `mgmt_allowed_cidrs` containing `0.0.0.0/0`, etc.).

| Variable | Description | Default |
|---|---|---|
| `primary_region` | Primary region location/code/environment | UK South / `uks` / `prod` |
| `secondary_region` | DR region location/code/environment | UK West / `ukw` / `dr` |
| `uks_hub_vnet` / `ukw_hub_vnet` | Hub VNet address space + subnet CIDRs | `10.10.0.0/16` / `10.20.0.0/16` |
| `uks_spokes` / `ukw_spokes` | Spoke VNet (`app1`, `app2`) address spaces | `10.11-12.0.0/16` / `10.21-22.0.0/16` |
| `firewall_vm_size` | Azure VM size for VM-Series | `Standard_D4s_v5` |
| `panos_image` | Marketplace image publisher/offer/sku/version | `paloaltonetworks/vmseries-flex/byol/12.1.7` (pinned — `"latest"` is rejected) |
| `uks_firewall` / `ukw_firewall` | Firewall name + NIC IPs | `pa-uks-fw01` / `pa-ukw-fw01` |
| `uks_internal_lb_frontend_ip` / `ukw_internal_lb_frontend_ip` | Internal LB static IP | `10.10.1.100` / `10.20.1.100` |
| `admin_username` | Firewall local admin username | `panadmin` |
| `admin_ssh_public_key` | Firewall local admin SSH public key | *(required, no default)* |
| `enable_mgmt_public_ip` | Attach a public IP to the mgmt NIC | `false` |
| `mgmt_allowed_cidrs` | CIDRs allowed to reach the mgmt interface | `["10.0.0.0/8"]` |
| `hub_peering_allow_gateway_transit` / `hub_peering_use_remote_gateways` | Hub-to-hub peering gateway options | `false` |
| `tags` | Extra tags merged into every resource's tag set | `{}` |

Run `terraform-docs markdown .` for a fully generated, always-current
inputs/outputs table if you have it installed.

## Outputs

See `outputs.tf` for the full list — resource group names, VNet IDs,
firewall management/trust/untrust IPs (public mgmt IP is `null` when
`enable_mgmt_public_ip` is `false`), load balancer IPs, and Log Analytics
workspace IDs for both regions.

## Usage

```bash
# 1. One-time backend bootstrap (see docs/backend.md), then:
terraform init -backend-config=backend.hcl

# 2. Accept the PAN-OS marketplace terms (see Prerequisites above) if this
#    is the first deployment in the subscription.

# 3. Copy and edit tfvars
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set admin_ssh_public_key at minimum

# 4. Plan and apply
terraform plan
terraform apply
```

`terraform.tfvars` is gitignored (`.gitignore`) so secrets never get
committed; only `terraform.tfvars.example` is tracked.

## Development / CI

- `terraform fmt -check -recursive` and `terraform validate` should pass
  before committing.
- `.terraform.lock.hcl` is committed and covers `windows_amd64` and
  `linux_amd64` — run `terraform init` (not `-upgrade`) to reuse the locked
  `azurerm` provider version.
- GitHub Actions (`.github/workflows/terraform.yml`) runs `fmt`,
  `validate`, `tflint`, and `checkov` on every pull request — see that
  workflow for details.
