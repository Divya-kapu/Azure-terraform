provider "azurerm" {
  features {}
  
}

resource "azurerm_resource_group" "demo" {
   name = var.rg_name
   location = var.location
}
