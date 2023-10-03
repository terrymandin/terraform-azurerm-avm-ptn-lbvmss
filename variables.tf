variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetry.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# Required variables
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "location" {
  type        = string
  description = "The region where the resources will be deployed."
}

variable "virtual_machine_scale_set" {
  type = object({
    name      = string
    sku_name  = optional(string, "Standard_D2s_v4")
    instances = optional(number, 1)
    capacity_reservation_group_id = optional(string, null)
    automatic_instance_repair = optional(object({
      enabled      = optional(bool, false)
      grace_period = optional(number, 30)
    }), {})
    os_profile = object({
      linux_configuration = optional(object({
        disable_password_authentication = optional(bool, false)
        admin_username                  = optional(string, null)
        admin_password                  = optional(string, null) # When an admin_ssh_key is specified admin_password must be set to null
        disable_password_authentication = optional(bool, true)
        admin_ssh_key = optional(object({   # This is not optional in the underlying module
          username   = optional(string, null)
          public_key = optional(string, null)
        }), {}) # When an admin_password is specified disable_password_authentication must be set to false
      }), {})
      windows_configuration = optional(object({
        admin_username           = optional(string, null) # underlying module will default to name if null
        admin_password           = optional(string, null) # underlying module will default to name if null
        computer_name_prefix     = optional(string, null) # underlying module will default to name if null
        enable_automatic_updates = optional(bool, true)
        hotpatching_enabled      = optional(bool, false)             # Requires detailed validation
        patch_assessment_mode    = optional(string, "ImageDefault")  # How to set options "AutomaticByPlatform" or "ImageDefault"
        patch_mode               = optional(string, "AutomaticByOS") # How to set options Manual, AutomaticByOS and AutomaticByPlatform
        provision_vm_agent       = optional(bool, true)
      }), {})
    })
  })   
}

variable load_balancer {
  type = object({
    name = string
    sku = optional(string, "Standard")
    ip = object({
      name = string
      allocation_method = optional(string, "Static")
      sku = optional(string, "Standard")
      zones = optional(list(string), ["1", "2", "3"])
      domain_name_label = string
    })
    frontend_ip_configuration = optional(object({
      name = optional(string, "myPublicIP")
    }), {})
    azurerm_lb_backend_address_pool = optional(object({
      name = optional(string, "myBackendAddressPool")
    }), {})
    rule = optional(object({
      name = optional(string, "http")
      protocol = optional(string, "Tcp")
      frontend_port = optional(number, 80)
      backend_port = optional(number, 80)
      frontend_ip_configuration_name = optional(string, "myPublicIP")
      backend_address_pool_id = optional(string, null)
      probe_id = optional(string, null)
    }), {})
    probe = optional(object({
      name = optional(string, "myProbe" )
      protocol = optional(string, "Http")
      port = optional(number, 80)
      request_path = optional(string, "/")
    }), {})
    nat_rule = optional(object({
      name = optional(string, "ssh")
      protocol = optional(string, "Tcp")
      frontend_port_start = optional(number, 50000)
      frontend_port_end = optional(number, 50119)
      backend_port = optional(number, 22)
    }), {})
  })
}

variable "virtual_network" {
  type = object({
    name = string
    address_space = optional(list(string), ["10.0.0.0/16"])
    subnet = object({
      name = optional(string, "mySubnet")
      address_prefix = optional(list(string), ["10.0.0.0/20"])
    })
    network_security_group = object({
      name = optional(string, "myNSG")
      security_rules = list(object({
        name = string
        priority = number
        direction = string
        access = string
        protocol = string
        source_port_range = string
        destination_port_range = string
        source_address_prefix = string
        destination_address_prefix = string
      }))
    })
    nat_gateway = object({
      name = optional(string, "myNatGateway")
      sku = optional(string, "Standard")
      zones = optional(list(string), ["1"])
      public_ip = object({
        name = string
        allocation_method = optional(string, "Static")
        sku = optional(string, "Standard")
        zones = optional(list(string), ["1"])
      })
    })
  })
}

