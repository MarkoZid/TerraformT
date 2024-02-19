terraform {
  backend "azurerm" {
    
    storage_account_name = "backendzid"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "backendzid"
  }
}