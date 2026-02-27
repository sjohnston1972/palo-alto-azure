# ============================================================
# UK South - Public Load Balancer
# Sits in front of the Untrust NIC (North-South inbound)
# ============================================================

resource "azurerm_public_ip" "uks_lb_public" {
  name                = "pip-${local.uks_public_lb_name}"
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_paloalto.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_lb" "uks_public" {
  name                = local.uks_public_lb_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_paloalto.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "frontend-public"
    public_ip_address_id = azurerm_public_ip.uks_lb_public.id
  }
}

resource "azurerm_lb_backend_address_pool" "uks_public" {
  name            = "backend-untrust"
  loadbalancer_id = azurerm_lb.uks_public.id
}

resource "azurerm_network_interface_backend_address_pool_association" "uks_untrust" {
  network_interface_id    = azurerm_network_interface.uks_fw_untrust.id
  ip_configuration_name   = "ipconfig-untrust"
  backend_address_pool_id = azurerm_lb_backend_address_pool.uks_public.id
}

resource "azurerm_lb_probe" "uks_public" {
  name            = "probe-https"
  loadbalancer_id = azurerm_lb.uks_public.id
  protocol        = "Tcp"
  port            = 443
}

# Add inbound NAT rules or LB rules per application requirement.
# Example rule included for HTTPS; expand as needed.
resource "azurerm_lb_rule" "uks_public_https" {
  name                           = "rule-https-inbound"
  loadbalancer_id                = azurerm_lb.uks_public.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "frontend-public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.uks_public.id]
  probe_id                       = azurerm_lb_probe.uks_public.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 4
}

# ============================================================
# UK South - Internal Load Balancer
# Sits behind the Trust NIC (East-West / spoke egress)
# Uses HA Ports to pass all protocols to the firewall.
# ============================================================

resource "azurerm_lb" "uks_internal" {
  name                = local.uks_internal_lb_name
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_paloalto.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                          = "frontend-internal"
    subnet_id                     = azurerm_subnet.uks_trust.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.uks_internal_lb_frontend_ip
  }
}

resource "azurerm_lb_backend_address_pool" "uks_internal" {
  name            = "backend-trust"
  loadbalancer_id = azurerm_lb.uks_internal.id
}

resource "azurerm_network_interface_backend_address_pool_association" "uks_trust" {
  network_interface_id    = azurerm_network_interface.uks_fw_trust.id
  ip_configuration_name   = "ipconfig-trust"
  backend_address_pool_id = azurerm_lb_backend_address_pool.uks_internal.id
}

resource "azurerm_lb_probe" "uks_internal" {
  name            = "probe-ssh"
  loadbalancer_id = azurerm_lb.uks_internal.id
  protocol        = "Tcp"
  port            = 22
}

# HA Ports rule: forwards all traffic (all protocols, all ports) to the firewall
resource "azurerm_lb_rule" "uks_internal_ha" {
  name                           = "rule-ha-ports"
  loadbalancer_id                = azurerm_lb.uks_internal.id
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "frontend-internal"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.uks_internal.id]
  probe_id                       = azurerm_lb_probe.uks_internal.id
  enable_floating_ip             = true
  idle_timeout_in_minutes        = 4
}

# ============================================================
# UK West - Public Load Balancer
# ============================================================

resource "azurerm_public_ip" "ukw_lb_public" {
  name                = "pip-${local.ukw_public_lb_name}"
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_paloalto.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_lb" "ukw_public" {
  name                = local.ukw_public_lb_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_paloalto.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                 = "frontend-public"
    public_ip_address_id = azurerm_public_ip.ukw_lb_public.id
  }
}

resource "azurerm_lb_backend_address_pool" "ukw_public" {
  name            = "backend-untrust"
  loadbalancer_id = azurerm_lb.ukw_public.id
}

resource "azurerm_network_interface_backend_address_pool_association" "ukw_untrust" {
  network_interface_id    = azurerm_network_interface.ukw_fw_untrust.id
  ip_configuration_name   = "ipconfig-untrust"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ukw_public.id
}

resource "azurerm_lb_probe" "ukw_public" {
  name            = "probe-https"
  loadbalancer_id = azurerm_lb.ukw_public.id
  protocol        = "Tcp"
  port            = 443
}

resource "azurerm_lb_rule" "ukw_public_https" {
  name                           = "rule-https-inbound"
  loadbalancer_id                = azurerm_lb.ukw_public.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "frontend-public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ukw_public.id]
  probe_id                       = azurerm_lb_probe.ukw_public.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 4
}

# ============================================================
# UK West - Internal Load Balancer
# ============================================================

resource "azurerm_lb" "ukw_internal" {
  name                = local.ukw_internal_lb_name
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_paloalto.name
  sku                 = "Standard"
  tags                = local.common_tags

  frontend_ip_configuration {
    name                          = "frontend-internal"
    subnet_id                     = azurerm_subnet.ukw_trust.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ukw_internal_lb_frontend_ip
  }
}

resource "azurerm_lb_backend_address_pool" "ukw_internal" {
  name            = "backend-trust"
  loadbalancer_id = azurerm_lb.ukw_internal.id
}

resource "azurerm_network_interface_backend_address_pool_association" "ukw_trust" {
  network_interface_id    = azurerm_network_interface.ukw_fw_trust.id
  ip_configuration_name   = "ipconfig-trust"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ukw_internal.id
}

resource "azurerm_lb_probe" "ukw_internal" {
  name            = "probe-ssh"
  loadbalancer_id = azurerm_lb.ukw_internal.id
  protocol        = "Tcp"
  port            = 22
}

resource "azurerm_lb_rule" "ukw_internal_ha" {
  name                           = "rule-ha-ports"
  loadbalancer_id                = azurerm_lb.ukw_internal.id
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "frontend-internal"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ukw_internal.id]
  probe_id                       = azurerm_lb_probe.ukw_internal.id
  enable_floating_ip             = true
  idle_timeout_in_minutes        = 4
}
