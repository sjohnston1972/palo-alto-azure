# ============================================================
# UK South Resource Groups
# ============================================================

resource "azurerm_resource_group" "uks_hub" {
  name     = local.uks_hub_rg_name
  location = var.primary_region.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "uks_paloalto" {
  name     = local.uks_palo_rg_name
  location = var.primary_region.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "uks_spoke_app1" {
  name     = local.uks_spoke1_rg_name
  location = var.primary_region.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "uks_spoke_app2" {
  name     = local.uks_spoke2_rg_name
  location = var.primary_region.location
  tags     = local.common_tags
}

# ============================================================
# UK West Resource Groups
# ============================================================

resource "azurerm_resource_group" "ukw_hub" {
  name     = local.ukw_hub_rg_name
  location = var.secondary_region.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "ukw_paloalto" {
  name     = local.ukw_palo_rg_name
  location = var.secondary_region.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "ukw_spoke_app1" {
  name     = local.ukw_spoke1_rg_name
  location = var.secondary_region.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "ukw_spoke_app2" {
  name     = local.ukw_spoke2_rg_name
  location = var.secondary_region.location
  tags     = local.common_tags
}
