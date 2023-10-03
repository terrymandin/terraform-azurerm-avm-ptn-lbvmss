resource "random_pet" "lb_hostname" {
}

# A public IP address for the load balancer
resource "azurerm_public_ip" "example" {
  name                = var.load_balancer.ip.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.load_balancer.ip.allocation_method
  sku                 = var.load_balancer.ip.sku
  zones               = var.load_balancer.ip.zones
  domain_name_label   = var.load_balancer.ip.domain_name_label
}

# A load balancer with a frontend IP configuration and a backend address pool
resource "azurerm_lb" "example" {
  name                = var.load_balancer.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.load_balancer.sku
  frontend_ip_configuration {
    name                 = var.load_balancer.frontend_ip_configuration.name
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "bepool" {
  name            = var.load_balancer.azurerm_lb_backend_address_pool.name
  loadbalancer_id = azurerm_lb.example.id
}

#set up load balancer rule from azurerm_lb.example frontend ip to azurerm_lb_backend_address_pool.bepool backend ip port 80 to port 80
resource "azurerm_lb_rule" "example" {
  name                           = var.load_balancer.rule.name
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = var.load_balancer.rule.protocol
  frontend_port                  = var.load_balancer.rule.frontend_port
  backend_port                   = var.load_balancer.rule.backend_port
  frontend_ip_configuration_name = var.load_balancer.rule.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bepool.id]
  probe_id                       = azurerm_lb_probe.example.id
}

#set up load balancer probe to check if the backend is up
resource "azurerm_lb_probe" "example" {
  name            = var.load_balancer.probe.name
  loadbalancer_id = azurerm_lb.example.id
  protocol        = var.load_balancer.probe.protocol
  port            = var.load_balancer.probe.port
  request_path    = var.load_balancer.probe.request_path
}

#add lb nat rules to allow ssh access to the backend instances
resource "azurerm_lb_nat_rule" "ssh" {
  name                           = var.load_balancer.nat_rule.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = var.load_balancer.nat_rule.protocol
  frontend_port_start            = var.load_balancer.nat_rule.frontend_port_start
  frontend_port_end              = var.load_balancer.nat_rule.frontend_port_end
  backend_port                   = var.load_balancer.nat_rule.backend_port
  frontend_ip_configuration_name = var.load_balancer.frontend_ip_configuration.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool.id
}
