# Remote state backend bootstrap

This project stores Terraform state remotely in Azure Storage using the
`azurerm` backend, configured with [partial configuration](https://developer.hashicorp.com/terraform/language/backend#partial-configuration)
(see the empty `backend "azurerm" {}` block in `versions.tf`). No account
keys, SAS tokens, or subscription IDs are committed to the repository —
these are supplied at `terraform init` time via a local, gitignored
`backend.hcl` file.

The backing storage account, resource group, and container must exist
**before** you can run `terraform init`. This is a one-time bootstrap step,
not managed by this Terraform configuration itself (a backend cannot
reliably create its own storage).

## 1. Create the backend storage account

Pick a globally-unique storage account name (storage account names must be
3-24 characters, lowercase letters and numbers only). Example using the
Azure CLI:

```bash
az group create \
  --name rg-tfstate \
  --location uksouth

az storage account create \
  --name sttfstateXXXX \
  --resource-group rg-tfstate \
  --location uksouth \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

az storage container create \
  --name tfstate \
  --account-name sttfstateXXXX \
  --auth-mode login
```

Replace `sttfstateXXXX` with your chosen account name. Enabling versioning
and soft delete on the storage account is strongly recommended so an
accidental `terraform apply` or state corruption can be recovered:

```bash
az storage account blob-service-properties update \
  --account-name sttfstateXXXX \
  --resource-group rg-tfstate \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 30
```

## 2. Create `backend.hcl`

In the repo root, create a `backend.hcl` file (this filename is already
covered by `.gitignore` — **never commit it**) with the concrete values for
your environment:

```hcl
resource_group_name  = "rg-tfstate"
storage_account_name = "sttfstateXXXX"
container_name       = "tfstate"
key                  = "palo-alto-azure.tfstate"
```

Share this file with collaborators through a secure channel (a secrets
manager, encrypted vault, etc.) — not through git, chat, or email in plain
text. None of the values above are secret on their own, but the file
should still be handled consistently with the rest of the backend
configuration to avoid accidental drift between contributors.

## 3. Initialise Terraform

```bash
terraform init -backend-config=backend.hcl
```

This downloads providers and configures the `azurerm` backend to read and
write state from the blob container created above. Terraform authenticates
to the storage account using your existing Azure CLI login
(`az login`) by default — no storage account key needs to be embedded
anywhere.

Confirm no local state file is created:

```bash
ls terraform.tfstate 2>/dev/null || echo "no local state file (expected)"
```

## 4. Everyday use

Once initialised, use Terraform as normal — `terraform plan`,
`terraform apply`, etc. all read/write state from the remote blob, and the
backend provides locking so two people cannot run `apply` concurrently
against the same state.

If you ever need to re-point at a different backend configuration (e.g. a
different environment), rerun step 3 with an updated `backend.hcl`; add
`-reconfigure` or `-migrate-state` as appropriate.
