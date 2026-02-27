# ============================================================
# UK South - Log Analytics Workspace
# ============================================================

resource "azurerm_log_analytics_workspace" "uks" {
  name                = local.uks_law_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_hub.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.common_tags
}

# ============================================================
# UK West - Log Analytics Workspace
# ============================================================

resource "azurerm_log_analytics_workspace" "ukw" {
  name                = local.ukw_law_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_hub.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.common_tags
}

# ============================================================
# Diagnostic Settings - UKS Firewall NICs
# ============================================================

resource "azurerm_monitor_diagnostic_setting" "uks_fw_vm" {
  name                       = "diag-${var.uks_firewall.name}"
  target_resource_id         = azurerm_linux_virtual_machine.uks_firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.uks.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "uks_public_lb" {
  name                       = "diag-${local.uks_public_lb_name}"
  target_resource_id         = azurerm_lb.uks_public.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.uks.id

  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_log {
    category = "LoadBalancerProbeHealthStatus"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "uks_internal_lb" {
  name                       = "diag-${local.uks_internal_lb_name}"
  target_resource_id         = azurerm_lb.uks_internal.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.uks.id

  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_log {
    category = "LoadBalancerProbeHealthStatus"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# ============================================================
# Diagnostic Settings - UKW Firewall
# ============================================================

resource "azurerm_monitor_diagnostic_setting" "ukw_fw_vm" {
  name                       = "diag-${var.ukw_firewall.name}"
  target_resource_id         = azurerm_linux_virtual_machine.ukw_firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.ukw.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "ukw_public_lb" {
  name                       = "diag-${local.ukw_public_lb_name}"
  target_resource_id         = azurerm_lb.ukw_public.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.ukw.id

  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_log {
    category = "LoadBalancerProbeHealthStatus"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "ukw_internal_lb" {
  name                       = "diag-${local.ukw_internal_lb_name}"
  target_resource_id         = azurerm_lb.ukw_internal.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.ukw.id

  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_log {
    category = "LoadBalancerProbeHealthStatus"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
