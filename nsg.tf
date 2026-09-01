# ============================================================
# UK South NSGs
# ============================================================

resource "azurerm_network_security_group" "uks_mgmt" {
  name                = local.uks_mgmt_nsg_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_hub.name
  tags                = local.uks_tags

  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.mgmt_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.mgmt_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Panorama-Inbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3978"
    source_address_prefixes    = var.mgmt_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "uks_mgmt" {
  subnet_id                 = azurerm_subnet.uks_mgmt.id
  network_security_group_id = azurerm_network_security_group.uks_mgmt.id
}

resource "azurerm_network_security_group" "uks_untrust" {
  name                = local.uks_untrust_nsg_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_hub.name
  tags                = local.uks_tags

  # Scoped to what the public load balancer actually publishes (TCP 443 —
  # see load_balancers.tf) rather than allowing all protocols/ports from the
  # internet. Palo Alto still applies its own policy on top of this, but the
  # NSG no longer relies solely on the appliance to reject unpublished
  # traffic, and the Deny-All-Inbound fallback below gives NSG-level tooling
  # something to alert on.
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "uks_untrust" {
  subnet_id                 = azurerm_subnet.uks_untrust.id
  network_security_group_id = azurerm_network_security_group.uks_untrust.id
}

resource "azurerm_network_security_group" "uks_trust" {
  name                = local.uks_trust_nsg_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_hub.name
  tags                = local.uks_tags

  # East-west traffic from the UKS spoke VNets, forwarded to the firewall
  # trust interface via the internal load balancer (HA Ports rule passes all
  # protocols/ports, so source IPs remain the original spoke workload IPs).
  security_rule {
    name                       = "Allow-Spoke-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = [var.uks_spokes.app1.address_space, var.uks_spokes.app2.address_space]
    destination_address_prefix = "*"
  }

  # Azure Load Balancer health probe for the internal LB (probe-ssh, TCP 22).
  security_rule {
    name                       = "Allow-AzureLoadBalancer-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "uks_trust" {
  subnet_id                 = azurerm_subnet.uks_trust.id
  network_security_group_id = azurerm_network_security_group.uks_trust.id
}

# ============================================================
# UK West NSGs
# ============================================================

resource "azurerm_network_security_group" "ukw_mgmt" {
  name                = local.ukw_mgmt_nsg_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_hub.name
  tags                = local.ukw_tags

  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.mgmt_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.mgmt_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Panorama-Inbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3978"
    source_address_prefixes    = var.mgmt_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ukw_mgmt" {
  subnet_id                 = azurerm_subnet.ukw_mgmt.id
  network_security_group_id = azurerm_network_security_group.ukw_mgmt.id
}

resource "azurerm_network_security_group" "ukw_untrust" {
  name                = local.ukw_untrust_nsg_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_hub.name
  tags                = local.ukw_tags

  # Scoped to what the public load balancer actually publishes (TCP 443 —
  # see load_balancers.tf) rather than allowing all protocols/ports from the
  # internet. Palo Alto still applies its own policy on top of this, but the
  # NSG no longer relies solely on the appliance to reject unpublished
  # traffic, and the Deny-All-Inbound fallback below gives NSG-level tooling
  # something to alert on.
  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ukw_untrust" {
  subnet_id                 = azurerm_subnet.ukw_untrust.id
  network_security_group_id = azurerm_network_security_group.ukw_untrust.id
}

resource "azurerm_network_security_group" "ukw_trust" {
  name                = local.ukw_trust_nsg_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_hub.name
  tags                = local.ukw_tags

  # East-west traffic from the UKW spoke VNets, forwarded to the firewall
  # trust interface via the internal load balancer (HA Ports rule passes all
  # protocols/ports, so source IPs remain the original spoke workload IPs).
  security_rule {
    name                       = "Allow-Spoke-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = [var.ukw_spokes.app1.address_space, var.ukw_spokes.app2.address_space]
    destination_address_prefix = "*"
  }

  # Azure Load Balancer health probe for the internal LB (probe-ssh, TCP 22).
  security_rule {
    name                       = "Allow-AzureLoadBalancer-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ukw_trust" {
  subnet_id                 = azurerm_subnet.ukw_trust.id
  network_security_group_id = azurerm_network_security_group.ukw_trust.id
}

# ============================================================
# UK South Spoke Workload NSGs
# Default-deny inbound; the VirtualNetwork tag also covers traffic
# returning from the peered hub (e.g. the firewall trust interface)
# since Azure's VirtualNetwork service tag includes peered VNets.
# ============================================================

resource "azurerm_network_security_group" "uks_app1_workload" {
  name                = local.uks_app1_workload_nsg_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_spoke_app1.name
  tags                = local.uks_tags

  security_rule {
    name                       = "Allow-VirtualNetwork-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "uks_app1_workload" {
  subnet_id                 = azurerm_subnet.uks_app1_workload.id
  network_security_group_id = azurerm_network_security_group.uks_app1_workload.id
}

resource "azurerm_network_security_group" "uks_app2_workload" {
  name                = local.uks_app2_workload_nsg_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_spoke_app2.name
  tags                = local.uks_tags

  security_rule {
    name                       = "Allow-VirtualNetwork-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "uks_app2_workload" {
  subnet_id                 = azurerm_subnet.uks_app2_workload.id
  network_security_group_id = azurerm_network_security_group.uks_app2_workload.id
}

# ============================================================
# UK West Spoke Workload NSGs
# ============================================================

resource "azurerm_network_security_group" "ukw_app1_workload" {
  name                = local.ukw_app1_workload_nsg_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_spoke_app1.name
  tags                = local.ukw_tags

  security_rule {
    name                       = "Allow-VirtualNetwork-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ukw_app1_workload" {
  subnet_id                 = azurerm_subnet.ukw_app1_workload.id
  network_security_group_id = azurerm_network_security_group.ukw_app1_workload.id
}

resource "azurerm_network_security_group" "ukw_app2_workload" {
  name                = local.ukw_app2_workload_nsg_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_spoke_app2.name
  tags                = local.ukw_tags

  security_rule {
    name                       = "Allow-VirtualNetwork-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ukw_app2_workload" {
  subnet_id                 = azurerm_subnet.ukw_app2_workload.id
  network_security_group_id = azurerm_network_security_group.ukw_app2_workload.id
}
