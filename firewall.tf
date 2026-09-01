# ============================================================
# Marketplace Agreement
# Accept once per subscription: terraform apply -target=azurerm_marketplace_agreement.paloalto
# Comment out after first apply if re-running in same subscription.
# ============================================================

# resource "azurerm_marketplace_agreement" "paloalto" {
#   publisher = var.panos_image.publisher
#   offer     = var.panos_image.offer
#   plan      = var.panos_image.sku
# }

# ============================================================
# UK South - Public IPs
# ============================================================

resource "azurerm_public_ip" "uks_fw_mgmt" {
  name                = "pip-${var.uks_firewall.name}-mgmt"
  location            = var.primary_region.location
  resource_group_name = azurerm_resource_group.uks_paloalto.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.uks_tags
}

# ============================================================
# UK South - NICs
# NIC order matters for PAN-OS:
#   nic[0] = MGMT (primary, out-of-band)
#   nic[1] = ethernet1/1 (Untrust)
#   nic[2] = ethernet1/2 (Trust)
# ============================================================

resource "azurerm_network_interface" "uks_fw_mgmt" {
  name                          = "nic-${var.uks_firewall.name}-mgmt"
  location                      = var.primary_region.location
  resource_group_name           = azurerm_resource_group.uks_paloalto.name
  enable_accelerated_networking = false
  tags                          = local.uks_tags

  ip_configuration {
    name                          = "ipconfig-mgmt"
    subnet_id                     = azurerm_subnet.uks_mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.uks_firewall.mgmt_ip
    public_ip_address_id          = azurerm_public_ip.uks_fw_mgmt.id
  }
}

resource "azurerm_network_interface" "uks_fw_untrust" {
  name                          = "nic-${var.uks_firewall.name}-untrust"
  location                      = var.primary_region.location
  resource_group_name           = azurerm_resource_group.uks_paloalto.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = local.uks_tags

  ip_configuration {
    name                          = "ipconfig-untrust"
    subnet_id                     = azurerm_subnet.uks_untrust.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.uks_firewall.untrust_ip
  }
}

resource "azurerm_network_interface" "uks_fw_trust" {
  name                          = "nic-${var.uks_firewall.name}-trust"
  location                      = var.primary_region.location
  resource_group_name           = azurerm_resource_group.uks_paloalto.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = local.uks_tags

  ip_configuration {
    name                          = "ipconfig-trust"
    subnet_id                     = azurerm_subnet.uks_trust.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.uks_firewall.trust_ip
  }
}

# ============================================================
# UK South - VM-Series Firewall
# ============================================================

resource "azurerm_linux_virtual_machine" "uks_firewall" {
  name                            = var.uks_firewall.name
  location                        = var.primary_region.location
  resource_group_name             = azurerm_resource_group.uks_paloalto.name
  size                            = var.firewall_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  allow_extension_operations      = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  # NIC order: mgmt first (primary), then dataplane NICs
  network_interface_ids = [
    azurerm_network_interface.uks_fw_mgmt.id,
    azurerm_network_interface.uks_fw_untrust.id,
    azurerm_network_interface.uks_fw_trust.id,
  ]

  os_disk {
    name                 = "osdisk-${var.uks_firewall.name}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = var.panos_image.publisher
    offer     = var.panos_image.offer
    sku       = var.panos_image.sku
    version   = var.panos_image.version
  }

  plan {
    name      = var.panos_image.sku
    publisher = var.panos_image.publisher
    product   = var.panos_image.offer
  }

  boot_diagnostics {}

  tags = local.uks_tags

  depends_on = [
    azurerm_network_interface.uks_fw_mgmt,
    azurerm_network_interface.uks_fw_untrust,
    azurerm_network_interface.uks_fw_trust,
  ]
}

# ============================================================
# UK West - Public IPs
# ============================================================

resource "azurerm_public_ip" "ukw_fw_mgmt" {
  name                = "pip-${var.ukw_firewall.name}-mgmt"
  location            = var.secondary_region.location
  resource_group_name = azurerm_resource_group.ukw_paloalto.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.ukw_tags
}

# ============================================================
# UK West - NICs
# ============================================================

resource "azurerm_network_interface" "ukw_fw_mgmt" {
  name                          = "nic-${var.ukw_firewall.name}-mgmt"
  location                      = var.secondary_region.location
  resource_group_name           = azurerm_resource_group.ukw_paloalto.name
  enable_accelerated_networking = false
  tags                          = local.ukw_tags

  ip_configuration {
    name                          = "ipconfig-mgmt"
    subnet_id                     = azurerm_subnet.ukw_mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ukw_firewall.mgmt_ip
    public_ip_address_id          = azurerm_public_ip.ukw_fw_mgmt.id
  }
}

resource "azurerm_network_interface" "ukw_fw_untrust" {
  name                          = "nic-${var.ukw_firewall.name}-untrust"
  location                      = var.secondary_region.location
  resource_group_name           = azurerm_resource_group.ukw_paloalto.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = local.ukw_tags

  ip_configuration {
    name                          = "ipconfig-untrust"
    subnet_id                     = azurerm_subnet.ukw_untrust.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ukw_firewall.untrust_ip
  }
}

resource "azurerm_network_interface" "ukw_fw_trust" {
  name                          = "nic-${var.ukw_firewall.name}-trust"
  location                      = var.secondary_region.location
  resource_group_name           = azurerm_resource_group.ukw_paloalto.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = local.ukw_tags

  ip_configuration {
    name                          = "ipconfig-trust"
    subnet_id                     = azurerm_subnet.ukw_trust.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ukw_firewall.trust_ip
  }
}

# ============================================================
# UK West - VM-Series Firewall
# ============================================================

resource "azurerm_linux_virtual_machine" "ukw_firewall" {
  name                            = var.ukw_firewall.name
  location                        = var.secondary_region.location
  resource_group_name             = azurerm_resource_group.ukw_paloalto.name
  size                            = var.firewall_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  allow_extension_operations      = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.ukw_fw_mgmt.id,
    azurerm_network_interface.ukw_fw_untrust.id,
    azurerm_network_interface.ukw_fw_trust.id,
  ]

  os_disk {
    name                 = "osdisk-${var.ukw_firewall.name}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = var.panos_image.publisher
    offer     = var.panos_image.offer
    sku       = var.panos_image.sku
    version   = var.panos_image.version
  }

  plan {
    name      = var.panos_image.sku
    publisher = var.panos_image.publisher
    product   = var.panos_image.offer
  }

  boot_diagnostics {}

  tags = local.ukw_tags

  depends_on = [
    azurerm_network_interface.ukw_fw_mgmt,
    azurerm_network_interface.ukw_fw_untrust,
    azurerm_network_interface.ukw_fw_trust,
  ]
}
