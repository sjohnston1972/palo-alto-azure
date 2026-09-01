# ============================================================
# UK South - Hub VNet
# ============================================================

resource "azurerm_virtual_network" "uks_hub" {
  name                = local.uks_hub_vnet_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_hub.name
  address_space       = [var.uks_hub_vnet.address_space]
  tags                = local.uks_tags
}

resource "azurerm_subnet" "uks_azfw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.uks_hub.name
  virtual_network_name = azurerm_virtual_network.uks_hub.name
  address_prefixes     = [var.uks_hub_vnet.subnet_azfw]
}

resource "azurerm_subnet" "uks_trust" {
  name                 = "Palo-Trust"
  resource_group_name  = azurerm_resource_group.uks_hub.name
  virtual_network_name = azurerm_virtual_network.uks_hub.name
  address_prefixes     = [var.uks_hub_vnet.subnet_trust]
}

resource "azurerm_subnet" "uks_untrust" {
  name                 = "Palo-Untrust"
  resource_group_name  = azurerm_resource_group.uks_hub.name
  virtual_network_name = azurerm_virtual_network.uks_hub.name
  address_prefixes     = [var.uks_hub_vnet.subnet_untrust]
}

resource "azurerm_subnet" "uks_mgmt" {
  name                 = "Palo-Management"
  resource_group_name  = azurerm_resource_group.uks_hub.name
  virtual_network_name = azurerm_virtual_network.uks_hub.name
  address_prefixes     = [var.uks_hub_vnet.subnet_mgmt]
}

resource "azurerm_subnet" "uks_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.uks_hub.name
  virtual_network_name = azurerm_virtual_network.uks_hub.name
  address_prefixes     = [var.uks_hub_vnet.subnet_gateway]
}

# ============================================================
# UK South - Spoke VNets
# ============================================================

resource "azurerm_virtual_network" "uks_app1" {
  name                = local.uks_app1_vnet_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_spoke_app1.name
  address_space       = [var.uks_spokes.app1.address_space]
  tags                = local.uks_tags
}

resource "azurerm_subnet" "uks_app1_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.uks_spoke_app1.name
  virtual_network_name = azurerm_virtual_network.uks_app1.name
  address_prefixes     = [var.uks_spokes.app1.workload_subnet]
}

resource "azurerm_virtual_network" "uks_app2" {
  name                = local.uks_app2_vnet_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_spoke_app2.name
  address_space       = [var.uks_spokes.app2.address_space]
  tags                = local.uks_tags
}

resource "azurerm_subnet" "uks_app2_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.uks_spoke_app2.name
  virtual_network_name = azurerm_virtual_network.uks_app2.name
  address_prefixes     = [var.uks_spokes.app2.workload_subnet]
}

# ============================================================
# UK West - Hub VNet
# ============================================================

resource "azurerm_virtual_network" "ukw_hub" {
  name                = local.ukw_hub_vnet_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_hub.name
  address_space       = [var.ukw_hub_vnet.address_space]
  tags                = local.ukw_tags
}

resource "azurerm_subnet" "ukw_trust" {
  name                 = "Palo-Trust"
  resource_group_name  = azurerm_resource_group.ukw_hub.name
  virtual_network_name = azurerm_virtual_network.ukw_hub.name
  address_prefixes     = [var.ukw_hub_vnet.subnet_trust]
}

resource "azurerm_subnet" "ukw_untrust" {
  name                 = "Palo-Untrust"
  resource_group_name  = azurerm_resource_group.ukw_hub.name
  virtual_network_name = azurerm_virtual_network.ukw_hub.name
  address_prefixes     = [var.ukw_hub_vnet.subnet_untrust]
}

resource "azurerm_subnet" "ukw_mgmt" {
  name                 = "Palo-Management"
  resource_group_name  = azurerm_resource_group.ukw_hub.name
  virtual_network_name = azurerm_virtual_network.ukw_hub.name
  address_prefixes     = [var.ukw_hub_vnet.subnet_mgmt]
}

resource "azurerm_subnet" "ukw_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.ukw_hub.name
  virtual_network_name = azurerm_virtual_network.ukw_hub.name
  address_prefixes     = [var.ukw_hub_vnet.subnet_gateway]
}

# ============================================================
# UK West - Spoke VNets
# ============================================================

resource "azurerm_virtual_network" "ukw_app1" {
  name                = local.ukw_app1_vnet_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_spoke_app1.name
  address_space       = [var.ukw_spokes.app1.address_space]
  tags                = local.ukw_tags
}

resource "azurerm_subnet" "ukw_app1_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.ukw_spoke_app1.name
  virtual_network_name = azurerm_virtual_network.ukw_app1.name
  address_prefixes     = [var.ukw_spokes.app1.workload_subnet]
}

resource "azurerm_virtual_network" "ukw_app2" {
  name                = local.ukw_app2_vnet_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_spoke_app2.name
  address_space       = [var.ukw_spokes.app2.address_space]
  tags                = local.ukw_tags
}

resource "azurerm_subnet" "ukw_app2_workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.ukw_spoke_app2.name
  virtual_network_name = azurerm_virtual_network.ukw_app2.name
  address_prefixes     = [var.ukw_spokes.app2.workload_subnet]
}
