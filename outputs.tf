# ============================================================
# Resource Group IDs
# ============================================================

output "uks_hub_resource_group" {
  description = "UKS Hub resource group name"
  value       = azurerm_resource_group.uks_hub.name
}

output "ukw_hub_resource_group" {
  description = "UKW Hub resource group name"
  value       = azurerm_resource_group.ukw_hub.name
}

# ============================================================
# VNet IDs
# ============================================================

output "uks_hub_vnet_id" {
  description = "UKS Hub VNet ID"
  value       = azurerm_virtual_network.uks_hub.id
}

output "ukw_hub_vnet_id" {
  description = "UKW Hub VNet ID"
  value       = azurerm_virtual_network.ukw_hub.id
}

output "uks_app1_vnet_id" {
  description = "UKS App1 Spoke VNet ID"
  value       = azurerm_virtual_network.uks_app1.id
}

output "uks_app2_vnet_id" {
  description = "UKS App2 Spoke VNet ID"
  value       = azurerm_virtual_network.uks_app2.id
}

output "ukw_app1_vnet_id" {
  description = "UKW App1 Spoke VNet ID"
  value       = azurerm_virtual_network.ukw_app1.id
}

output "ukw_app2_vnet_id" {
  description = "UKW App2 Spoke VNet ID"
  value       = azurerm_virtual_network.ukw_app2.id
}

# ============================================================
# Firewall Management IPs
# ============================================================

output "uks_firewall_mgmt_public_ip" {
  description = "UKS Firewall management public IP (null when enable_mgmt_public_ip is false)"
  value       = try(azurerm_public_ip.uks_fw_mgmt[0].ip_address, null)
}

output "uks_firewall_mgmt_private_ip" {
  description = "UKS Firewall management private IP"
  value       = var.uks_firewall.mgmt_ip
}

output "uks_firewall_trust_ip" {
  description = "UKS Firewall Trust NIC private IP"
  value       = var.uks_firewall.trust_ip
}

output "uks_firewall_untrust_ip" {
  description = "UKS Firewall Untrust NIC private IP"
  value       = var.uks_firewall.untrust_ip
}

output "ukw_firewall_mgmt_public_ip" {
  description = "UKW Firewall management public IP (null when enable_mgmt_public_ip is false)"
  value       = try(azurerm_public_ip.ukw_fw_mgmt[0].ip_address, null)
}

output "ukw_firewall_mgmt_private_ip" {
  description = "UKW Firewall management private IP"
  value       = var.ukw_firewall.mgmt_ip
}

output "ukw_firewall_trust_ip" {
  description = "UKW Firewall Trust NIC private IP"
  value       = var.ukw_firewall.trust_ip
}

output "ukw_firewall_untrust_ip" {
  description = "UKW Firewall Untrust NIC private IP"
  value       = var.ukw_firewall.untrust_ip
}

# ============================================================
# Load Balancer IPs
# ============================================================

output "uks_public_lb_ip" {
  description = "UKS Public Load Balancer IP"
  value       = azurerm_public_ip.uks_lb_public.ip_address
}

output "uks_internal_lb_ip" {
  description = "UKS Internal Load Balancer frontend IP"
  value       = var.uks_internal_lb_frontend_ip
}

output "ukw_public_lb_ip" {
  description = "UKW Public Load Balancer IP"
  value       = azurerm_public_ip.ukw_lb_public.ip_address
}

output "ukw_internal_lb_ip" {
  description = "UKW Internal Load Balancer frontend IP"
  value       = var.ukw_internal_lb_frontend_ip
}

# ============================================================
# Log Analytics Workspace IDs
# ============================================================

output "uks_log_analytics_workspace_id" {
  description = "UKS Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.uks.id
}

output "ukw_log_analytics_workspace_id" {
  description = "UKW Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.ukw.id
}
