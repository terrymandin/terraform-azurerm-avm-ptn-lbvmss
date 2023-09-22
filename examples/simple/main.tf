module "load_balancer_scale_set" {    
    source = "../../"
    enable_telemetry = var.enable_telemetry
    resource_group_name = var.resource_group_name
    location = var.location
}