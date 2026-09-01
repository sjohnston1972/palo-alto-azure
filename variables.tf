# ============================================================
# Region Configuration
# ============================================================

variable "primary_region" {
  description = "Primary region settings"
  type = object({
    location    = string
    code        = string
    environment = string
  })
  default = {
    location    = "uksouth"
    code        = "uks"
    environment = "prod"
  }
}

variable "secondary_region" {
  description = "Secondary / DR region settings"
  type = object({
    location    = string
    code        = string
    environment = string
  })
  default = {
    location    = "ukwest"
    code        = "ukw"
    environment = "dr"
  }
}

# ============================================================
# Hub VNet Configuration
# ============================================================

variable "uks_hub_vnet" {
  description = "UK South Hub VNet address space and subnet CIDRs"
  type = object({
    address_space  = string
    subnet_azfw    = string # AzureFirewallSubnet (reserved for future use)
    subnet_trust   = string
    subnet_untrust = string
    subnet_mgmt    = string
    subnet_gateway = string # GatewaySubnet
  })
  default = {
    address_space  = "10.10.0.0/16"
    subnet_azfw    = "10.10.0.0/24"
    subnet_trust   = "10.10.1.0/24"
    subnet_untrust = "10.10.2.0/24"
    subnet_mgmt    = "10.10.3.0/24"
    subnet_gateway = "10.10.255.0/27"
  }
}

variable "ukw_hub_vnet" {
  description = "UK West Hub VNet address space and subnet CIDRs"
  type = object({
    address_space  = string
    subnet_trust   = string
    subnet_untrust = string
    subnet_mgmt    = string
    subnet_gateway = string
  })
  default = {
    address_space  = "10.20.0.0/16"
    subnet_trust   = "10.20.1.0/24"
    subnet_untrust = "10.20.2.0/24"
    subnet_mgmt    = "10.20.3.0/24"
    subnet_gateway = "10.20.255.0/27"
  }
}

# ============================================================
# Spoke VNet Configuration
# ============================================================

variable "uks_spokes" {
  description = "UK South spoke VNets (app1 and app2)"
  type = object({
    app1 = object({
      address_space   = string
      workload_subnet = string
    })
    app2 = object({
      address_space   = string
      workload_subnet = string
    })
  })
  default = {
    app1 = {
      address_space   = "10.11.0.0/16"
      workload_subnet = "10.11.0.0/24"
    }
    app2 = {
      address_space   = "10.12.0.0/16"
      workload_subnet = "10.12.0.0/24"
    }
  }
}

variable "ukw_spokes" {
  description = "UK West spoke VNets (app1 and app2)"
  type = object({
    app1 = object({
      address_space   = string
      workload_subnet = string
    })
    app2 = object({
      address_space   = string
      workload_subnet = string
    })
  })
  default = {
    app1 = {
      address_space   = "10.21.0.0/16"
      workload_subnet = "10.21.0.0/24"
    }
    app2 = {
      address_space   = "10.22.0.0/16"
      workload_subnet = "10.22.0.0/24"
    }
  }
}

# ============================================================
# Firewall VM Configuration
# ============================================================

variable "firewall_vm_size" {
  description = "Azure VM size for Palo Alto VM-Series"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "panos_image" {
  description = "Palo Alto VM-Series marketplace image details"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
  }
}

variable "uks_firewall" {
  description = "UK South Palo Alto firewall NIC IP assignments"
  type = object({
    name       = string
    untrust_ip = string
    trust_ip   = string
    mgmt_ip    = string
  })
  default = {
    name       = "pa-uks-fw01"
    untrust_ip = "10.10.2.4"
    trust_ip   = "10.10.1.4"
    mgmt_ip    = "10.10.3.4"
  }
}

variable "ukw_firewall" {
  description = "UK West Palo Alto firewall NIC IP assignments"
  type = object({
    name       = string
    untrust_ip = string
    trust_ip   = string
    mgmt_ip    = string
  })
  default = {
    name       = "pa-ukw-fw01"
    untrust_ip = "10.20.2.4"
    trust_ip   = "10.20.1.4"
    mgmt_ip    = "10.20.3.4"
  }
}

# ============================================================
# Load Balancer Configuration
# ============================================================

variable "uks_internal_lb_frontend_ip" {
  description = "Static private IP for UKS internal load balancer frontend (in trust subnet)"
  type        = string
  default     = "10.10.1.100"
}

variable "ukw_internal_lb_frontend_ip" {
  description = "Static private IP for UKW internal load balancer frontend (in trust subnet)"
  type        = string
  default     = "10.20.1.100"
}

# ============================================================
# Admin Credentials
# ============================================================

variable "admin_username" {
  description = "Local administrator username for Palo Alto VMs"
  type        = string
  default     = "panadmin"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the local administrator account on the Palo Alto VMs (used instead of password authentication)"
  type        = string
}

# ============================================================
# Management Access
# ============================================================

variable "mgmt_allowed_cidrs" {
  description = "CIDRs permitted inbound access to the firewall management interface (SSH/HTTPS)"
  type        = list(string)
  default     = ["10.0.0.0/8"] # Restrict further in production
}

# ============================================================
# Inter-Region Peering Options
# ============================================================

variable "hub_peering_allow_gateway_transit" {
  description = "Allow gateway transit on hub-to-hub VNet peering"
  type        = bool
  default     = false
}

variable "hub_peering_use_remote_gateways" {
  description = "Use remote gateways on hub-to-hub VNet peering"
  type        = bool
  default     = false
}

# ============================================================
# Tags
# ============================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
