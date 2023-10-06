<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

TODO: Provide instructions or links to spec to explain how to use this template.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (3.74.0)

- <a name="provider_random"></a> [random](#provider\_random) (3.5.1)

## Resources

The following resources are used by this module:

- [azurerm_lb.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) (resource)
- [azurerm_lb_backend_address_pool.bepool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) (resource)
- [azurerm_lb_nat_rule.ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_nat_rule) (resource)
- [azurerm_lb_probe.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) (resource)
- [azurerm_lb_rule.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) (resource)
- [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) (resource)
- [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) (resource)
- [azurerm_network_security_group.myNSG](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_network_security_rule.rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) (resource)
- [azurerm_orchestrated_virtual_machine_scale_set.virtual_machine_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/orchestrated_virtual_machine_scale_set) (resource)
- [azurerm_public_ip.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_public_ip.natgwpip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet_nat_gateway_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) (resource)
- [azurerm_subnet_network_security_group_association.myNSG](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) (resource)
- [azurerm_virtual_network.test](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_id.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [random_pet.lb_hostname](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer)

Description: n/a

Type:

```hcl
object({
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
```

### <a name="input_location"></a> [location](#input\_location)

Description: The region where the resources will be deployed.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

### <a name="input_virtual_machine_scale_set"></a> [virtual\_machine\_scale\_set](#input\_virtual\_machine\_scale\_set)

Description: n/a

Type:

```hcl
object({
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
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    os_disk = optional(object({
      storage_account_type = optional(string, "Premium_LRS")
      caching              = optional(string, "ReadWrite")
    }), {})
  })
```

### <a name="input_virtual_network"></a> [virtual\_network](#input\_virtual\_network)

Description: n/a

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetry.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

No modules.


<!-- END_TF_DOCS -->