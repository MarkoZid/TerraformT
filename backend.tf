terraform {
  backend "azurerm" {
    storage_account_name = "storagebackend1233"
    container_name       = "tfstate"
    key                  = "TerraformT/terraform.tfstate"
    resource_group_name  = "TeraMaraton"
  }
}