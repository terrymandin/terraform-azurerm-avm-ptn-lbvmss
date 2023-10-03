terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

# This picks a random region from the list of regions.
resource "random_integer" "region_index" {
  min = 0
  max = length(local.azure_regions) - 1
}

resource "random_pet" "domain_name_label" {
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

provider "azurerm" {
  features {}
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

resource "azurerm_resource_group" "this" {
  name     = "avm2"   #module.naming.resource_group.name_unique
  location = "eastus" #local.azure_regions[random_integer.region_index.result]
}

module "load_balancer_scale_set" {
  source              = "../../"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  virtual_machine_scale_set = {
    name = module.naming.virtual_machine_scale_set.name_unique
    os_profile = {
      linux_configuration = {
        disable_password_authentication = false
        admin_username                  = "azureuser"
        admin_password                  = "P@ssw0rd1234!"
        admin_ssh_key = {
          username   = "azureuser"
          public_key = file("c:/tmp/key.txt")
        }
      }
    }
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-LTS-gen2"
      version   = "latest"
    }
  }
  load_balancer = {
    name = module.naming.lb.name_unique
    ip = {
      name              = module.naming.public_ip.name_unique
      domain_name_label = random_pet.domain_name_label.id
    }
  }
  virtual_network = {
    name = module.naming.virtual_network.name_unique
    subnet = {
    }
    nat_gateway = {
      public_ip = {
        name = "${module.naming.public_ip.name_unique}-2"
      }
    }
    network_security_group = {
      security_rules = [
        {
          name                       = "allow-https"
          priority                   = 101
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-ssh"
          priority                   = 102
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-http"
          priority                   = 103
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

