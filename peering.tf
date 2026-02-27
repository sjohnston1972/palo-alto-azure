# ============================================================
# Hub-to-Hub Peering (Inter-Region)
# ============================================================

resource "azurerm_virtual_network_peering" "uks_hub_to_ukw_hub" {
  name                         = "peer-${var.primary_region.code}-hub-to-${var.secondary_region.code}-hub"
  resource_group_name          = azurerm_resource_group.uks_hub.name
  virtual_network_name         = azurerm_virtual_network.uks_hub.name
  remote_virtual_network_id    = azurerm_virtual_network.ukw_hub.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.hub_peering_allow_gateway_transit
  use_remote_gateways          = var.hub_peering_use_remote_gateways
}

resource "azurerm_virtual_network_peering" "ukw_hub_to_uks_hub" {
  name                         = "peer-${var.secondary_region.code}-hub-to-${var.primary_region.code}-hub"
  resource_group_name          = azurerm_resource_group.ukw_hub.name
  virtual_network_name         = azurerm_virtual_network.ukw_hub.name
  remote_virtual_network_id    = azurerm_virtual_network.uks_hub.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.hub_peering_allow_gateway_transit
  use_remote_gateways          = var.hub_peering_use_remote_gateways
}

# ============================================================
# UKS Hub <-> Spoke Peerings
# ============================================================

resource "azurerm_virtual_network_peering" "uks_hub_to_app1" {
  name                      = "peer-${var.primary_region.code}-hub-to-app1"
  resource_group_name       = azurerm_resource_group.uks_hub.name
  virtual_network_name      = azurerm_virtual_network.uks_hub.name
  remote_virtual_network_id = azurerm_virtual_network.uks_app1.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

resource "azurerm_virtual_network_peering" "uks_app1_to_hub" {
  name                      = "peer-${var.primary_region.code}-app1-to-hub"
  resource_group_name       = azurerm_resource_group.uks_spoke_app1.name
  virtual_network_name      = azurerm_virtual_network.uks_app1.name
  remote_virtual_network_id = azurerm_virtual_network.uks_hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "uks_hub_to_app2" {
  name                      = "peer-${var.primary_region.code}-hub-to-app2"
  resource_group_name       = azurerm_resource_group.uks_hub.name
  virtual_network_name      = azurerm_virtual_network.uks_hub.name
  remote_virtual_network_id = azurerm_virtual_network.uks_app2.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

resource "azurerm_virtual_network_peering" "uks_app2_to_hub" {
  name                      = "peer-${var.primary_region.code}-app2-to-hub"
  resource_group_name       = azurerm_resource_group.uks_spoke_app2.name
  virtual_network_name      = azurerm_virtual_network.uks_app2.name
  remote_virtual_network_id = azurerm_virtual_network.uks_hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

# ============================================================
# UKW Hub <-> Spoke Peerings
# ============================================================

resource "azurerm_virtual_network_peering" "ukw_hub_to_app1" {
  name                      = "peer-${var.secondary_region.code}-hub-to-app1"
  resource_group_name       = azurerm_resource_group.ukw_hub.name
  virtual_network_name      = azurerm_virtual_network.ukw_hub.name
  remote_virtual_network_id = azurerm_virtual_network.ukw_app1.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

resource "azurerm_virtual_network_peering" "ukw_app1_to_hub" {
  name                      = "peer-${var.secondary_region.code}-app1-to-hub"
  resource_group_name       = azurerm_resource_group.ukw_spoke_app1.name
  virtual_network_name      = azurerm_virtual_network.ukw_app1.name
  remote_virtual_network_id = azurerm_virtual_network.ukw_hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "ukw_hub_to_app2" {
  name                      = "peer-${var.secondary_region.code}-hub-to-app2"
  resource_group_name       = azurerm_resource_group.ukw_hub.name
  virtual_network_name      = azurerm_virtual_network.ukw_hub.name
  remote_virtual_network_id = azurerm_virtual_network.ukw_app2.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
}

resource "azurerm_virtual_network_peering" "ukw_app2_to_hub" {
  name                      = "peer-${var.secondary_region.code}-app2-to-hub"
  resource_group_name       = azurerm_resource_group.ukw_spoke_app2.name
  virtual_network_name      = azurerm_virtual_network.ukw_app2.name
  remote_virtual_network_id = azurerm_virtual_network.ukw_hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}
