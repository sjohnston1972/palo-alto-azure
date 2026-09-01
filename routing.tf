# ============================================================
# UK South - Route Table for Spokes
# Default route → Internal LB frontend IP (trust subnet)
# ============================================================

resource "azurerm_route_table" "uks_spokes" {
  name                          = local.uks_rt_name
  location                      = var.primary_region.location
  resource_group_name           = azurerm_resource_group.uks_hub.name
  disable_bgp_route_propagation = true
  tags                          = local.uks_tags

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.uks_firewall.trust_ip
  }
}

# Associate with UKS spoke subnets
resource "azurerm_subnet_route_table_association" "uks_app1_workload" {
  subnet_id      = azurerm_subnet.uks_app1_workload.id
  route_table_id = azurerm_route_table.uks_spokes.id
}

resource "azurerm_subnet_route_table_association" "uks_app2_workload" {
  subnet_id      = azurerm_subnet.uks_app2_workload.id
  route_table_id = azurerm_route_table.uks_spokes.id
}

# ============================================================
# UK West - Route Table for Spokes
# ============================================================

resource "azurerm_route_table" "ukw_spokes" {
  name                          = local.ukw_rt_name
  location                      = var.secondary_region.location
  resource_group_name           = azurerm_resource_group.ukw_hub.name
  disable_bgp_route_propagation = true
  tags                          = local.ukw_tags

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ukw_firewall.trust_ip
  }
}

# Associate with UKW spoke subnets
resource "azurerm_subnet_route_table_association" "ukw_app1_workload" {
  subnet_id      = azurerm_subnet.ukw_app1_workload.id
  route_table_id = azurerm_route_table.ukw_spokes.id
}

resource "azurerm_subnet_route_table_association" "ukw_app2_workload" {
  subnet_id      = azurerm_subnet.ukw_app2_workload.id
  route_table_id = azurerm_route_table.ukw_spokes.id
}
