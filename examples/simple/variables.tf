variable "enable_telemetry" {
  type        = bool
  default     = true
}

variable "resource_group_name" {
  type        = string
  default     = "lbvmssrg" # <TODO> Replace with unique name 
  description = "The resource group where the resources will be deployed."
}


variable "location" {
  type        = string
  default     = "eastus"
  description = "The region where the resources will be deployed."
}
