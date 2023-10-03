resource "azurerm_orchestrated_virtual_machine_scale_set" "virtual_machine_scale_set" {
  name                        = var.virtual_machine_scale_set.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku_name                    = var.virtual_machine_scale_set.sku_name
  instances                   = var.virtual_machine_scale_set.instances
  platform_fault_domain_count = 1               # For zonal deployments, this must be set to 1
  zones                       = ["1", "2", "3"] # Zones required to lookup zone in the startup script

  # user_data_base64 = base64encode(file("user-data.sh"))
  os_profile {
    linux_configuration {
      disable_password_authentication = true
      admin_username                  = var.virtual_machine_scale_set.os_profile.linux_configuration.admin_username
      admin_ssh_key {
        username   = var.virtual_machine_scale_set.os_profile.linux_configuration.admin_ssh_key.username
        public_key = var.virtual_machine_scale_set.os_profile.linux_configuration.admin_ssh_key.public_key
      }
    }
  }

  source_image_reference {
    publisher = var.virtual_machine_scale_set.source_image_reference.publisher
    offer     = var.virtual_machine_scale_set.source_image_reference.offer
    sku       = var.virtual_machine_scale_set.source_image_reference.sku
    version   = var.virtual_machine_scale_set.source_image_reference.version
  }

  os_disk {
    storage_account_type = var.virtual_machine_scale_set.os_disk.storage_account_type
    caching              = var.virtual_machine_scale_set.os_disk.caching
  }

  network_interface {
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name                                   = "ipconfig"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bepool.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = ""
  }

  # Ignore changes to the instances property, so that the VMSS is not recreated when the number of instances is changed
  lifecycle {
    ignore_changes = [
      instances
    ]
  }
}