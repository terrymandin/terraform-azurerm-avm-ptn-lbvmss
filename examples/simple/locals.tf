# We pick a random region from this list.  These regions support zonal deployments.
locals {
  azure_regions = [
    #"westeurope",
    #"northeurope",
    "eastus",
    #"eastus2",
    #"westus2",
    #"southcentralus",
    #"centralus",
  ]
}