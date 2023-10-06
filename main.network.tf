# Create an virtual network and subnet
resource "azurerm_virtual_network" "test" {
  name                = var.virtual_network.name
  address_space       = var.virtual_network.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = var.virtual_network.subnet.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = var.virtual_network.subnet.address_prefix
}

# network security group for the subnet with a rule to allow http, https and ssh traffic
resource "azurerm_network_security_group" "myNSG" {
  name                = var.virtual_network.network_security_group.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "rules" {
  for_each                  = { for rule in var.virtual_network.network_security_group.security_rules : rule.name => rule}
  name                      = each.key
  priority                  = each.value.priority
  direction                 = each.value.direction
  access                    = each.value.access
  protocol                  = each.value.protocol
  source_port_range         = each.value.source_port_range
  destination_port_range    = each.value.destination_port_range
  source_address_prefix     = each.value.source_address_prefix
  destination_address_prefix= each.value.destination_address_prefix  
  resource_group_name       = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.myNSG.name
}

resource "azurerm_subnet_network_security_group_association" "myNSG" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

resource "azurerm_public_ip" "natgwpip" {
  name                = var.virtual_network.nat_gateway.public_ip.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.virtual_network.nat_gateway.public_ip.allocation_method
  sku                 = var.virtual_network.nat_gateway.public_ip.sku
  zones               = var.virtual_network.nat_gateway.public_ip.zones
  tags                = var.tags
}

#add nat gateway to enable outbound traffic from the backend instances
resource "azurerm_nat_gateway" "this" {
  name                    = var.virtual_network.nat_gateway.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.virtual_network.nat_gateway.sku
  idle_timeout_in_minutes = 10
  zones                   = var.virtual_network.nat_gateway.zones 
  tags                    = var.tags
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

# add nat gateway public ip association
resource "azurerm_nat_gateway_public_ip_association" "this" {
  public_ip_address_id = azurerm_public_ip.natgwpip.id
  nat_gateway_id       = azurerm_nat_gateway.this.id
}
