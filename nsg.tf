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

  # Allow all inbound — Palo Alto handles policy on this interface
  security_rule {
    name                       = "Allow-All-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
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

  security_rule {
    name                       = "Allow-All-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
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
