# TODO: insert outputs here.

output "loadbalancer_id" {
  value = azurerm_lb.this.id
}

output "backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.bepool.id
}
