# ============================================================
# Computed names following convention: <type>-<region>-<workload>-<env>
# ============================================================

locals {

  # ---- Resource Group Names ----
  uks_hub_rg_name    = "rg-${var.primary_region.code}-network-hub-${var.primary_region.environment}"
  uks_palo_rg_name   = "rg-${var.primary_region.code}-paloalto-${var.primary_region.environment}"
  uks_spoke1_rg_name = "rg-${var.primary_region.code}-spoke-app1-${var.primary_region.environment}"
  uks_spoke2_rg_name = "rg-${var.primary_region.code}-spoke-app2-${var.primary_region.environment}"

  ukw_hub_rg_name    = "rg-${var.secondary_region.code}-network-hub-${var.secondary_region.environment}"
  ukw_palo_rg_name   = "rg-${var.secondary_region.code}-paloalto-${var.secondary_region.environment}"
  ukw_spoke1_rg_name = "rg-${var.secondary_region.code}-spoke-app1-${var.secondary_region.environment}"
  ukw_spoke2_rg_name = "rg-${var.secondary_region.code}-spoke-app2-${var.secondary_region.environment}"

  # ---- VNet Names ----
  uks_hub_vnet_name  = "vnet-${var.primary_region.code}-hub-${var.primary_region.environment}"
  uks_app1_vnet_name = "vnet-${var.primary_region.code}-app1-${var.primary_region.environment}"
  uks_app2_vnet_name = "vnet-${var.primary_region.code}-app2-${var.primary_region.environment}"

  ukw_hub_vnet_name  = "vnet-${var.secondary_region.code}-hub-${var.secondary_region.environment}"
  ukw_app1_vnet_name = "vnet-${var.secondary_region.code}-app1-${var.secondary_region.environment}"
  ukw_app2_vnet_name = "vnet-${var.secondary_region.code}-app2-${var.secondary_region.environment}"

  # ---- Load Balancer Names ----
  uks_public_lb_name   = "slb-${var.primary_region.code}-palo-public"
  uks_internal_lb_name = "slb-${var.primary_region.code}-palo-internal"

  ukw_public_lb_name   = "slb-${var.secondary_region.code}-palo-public"
  ukw_internal_lb_name = "slb-${var.secondary_region.code}-palo-internal"

  # ---- Route Table Names ----
  uks_rt_name = "rt-${var.primary_region.code}-spokes-default"
  ukw_rt_name = "rt-${var.secondary_region.code}-spokes-default"

  # ---- Log Analytics Names ----
  uks_law_name = "law-${var.primary_region.code}-secops"
  ukw_law_name = "law-${var.secondary_region.code}-secops"

  # ---- NSG Names ----
  uks_mgmt_nsg_name    = "nsg-${var.primary_region.code}-palo-mgmt"
  uks_untrust_nsg_name = "nsg-${var.primary_region.code}-palo-untrust"
  uks_trust_nsg_name   = "nsg-${var.primary_region.code}-palo-trust"
  ukw_mgmt_nsg_name    = "nsg-${var.secondary_region.code}-palo-mgmt"
  ukw_untrust_nsg_name = "nsg-${var.secondary_region.code}-palo-untrust"
  ukw_trust_nsg_name   = "nsg-${var.secondary_region.code}-palo-trust"

  # ---- Common Tags ----
  # Region-specific resources must use uks_tags / ukw_tags so DR (UK West)
  # resources are tagged with the secondary region's environment (e.g. "dr")
  # instead of inheriting the primary region's environment (e.g. "prod").
  uks_tags = merge(
    {
      ManagedBy   = "Terraform"
      Project     = "PaloAlto-DualRegion"
      Environment = var.primary_region.environment
    },
    var.tags
  )

  ukw_tags = merge(
    {
      ManagedBy   = "Terraform"
      Project     = "PaloAlto-DualRegion"
      Environment = var.secondary_region.environment
    },
    var.tags
  )
}
