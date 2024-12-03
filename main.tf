terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.0.0"
    }
  }
}
//deffefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {

    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    key_vault {
      purge_soft_delete_on_destroy    = true
      //recover_soft_deleted_key_vaults = true
    }
  }

  client_id = "f19a493e-6a62-425f-b5a8-24935c17af75"
  tenant_id = "84c31ca0-ac3b-4eae-ad11-519d80233e6f"
  client_secret = "Kfn8Q~u59g2CD2PvYl0FWTuBbiYEXrT0TJ.axcP0"
  subscription_id = "4f13db90-7175-430a-92c4-956419feab2e"

}

//aaaubauuu

data "azurerm_client_config" "current" {}

data "azuread_service_principal" "terraZid" {
  display_name = "ZidarTerraform2"
}

data "azuread_service_principal" "terraform" {
  display_name = var.display_name
}

# Create a resource group
resource "azurerm_resource_group" "marathon" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_service_plan" "marathon_service_plan" {
  name                = var.service_plan_name
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_resource_group.marathon.location
  sku_name            = "F1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "marathon_api" {
  name                = var.app_name_api
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    always_on = false
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v7.0"
    }

    cors {
      allowed_origins     = ["https://marathon-clientzid.azurewebsites.net"]
      support_credentials = true # Set to true if you want to allow credentials (like cookies or HTTP authentication) to be sent in the CORS request
    }

  }
}
//---
resource "azurerm_windows_web_app" "marathon_client" {
  name                = var.app_name_client
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    always_on = false
    application_stack {
      current_stack = "node"
      node_version  = "~18"
    }

     cors {
      allowed_origins     = ["https://marathon-apizid.azurewebsites.net"]
      support_credentials = true # Set to true if you want to allow credentials (like cookies or HTTP authentication) to be sent in the CORS request
    }

  }
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.marathon.name
  location                     = azurerm_resource_group.marathon.location
  version                      = "12.0"
  administrator_login          = "Bojan"
  administrator_login_password = "PreteshkoePomosh1@!"

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "mssql_database" {
  name      = var.sql_database_name
  server_id = azurerm_mssql_server.mssql_server.id
  sku_name  = "Basic"
  
  

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_redis_cache" "redis" {
  name                = var.redis_cache_name
  location            = azurerm_resource_group.marathon.location
  resource_group_name = azurerm_resource_group.marathon.name
  capacity            = 2
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azurerm_redis_firewall_rule" "redis_firewall" {
  name                = var.redis_name
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = azurerm_resource_group.marathon.name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}
//
resource "azurerm_mssql_firewall_rule" "dbfirewall" {
  name             = var.redis_firewall
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_key_vault" "key_vault" {
  name                     = var.key_vault_name
  location                 = azurerm_resource_group.marathon.location
  resource_group_name      = azurerm_resource_group.marathon.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false
  sku_name                 = "standard"

    //soft_delete_enabled = false 

    //konecno?
}

resource "azurerm_key_vault_access_policy" "zid_access" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.user_object_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}



resource "azurerm_key_vault_access_policy" "azurerm_key_vault_access_policy2" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.terraform.object_id
  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  #  depends_on = [
  #   //azurerm_key_vault_secret.key_vault_secret2,
  #   azurerm_key_vault_secret.key_vault_secret1

  # ]
}   

resource "azurerm_key_vault_secret" "key_vault_secret1" {
  name         = var.key_vault_secret_connection_string_name
  value        = "Server=tcp:${azurerm_mssql_server.mssql_server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login}@${azurerm_mssql_server.mssql_server.name};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [
    azurerm_key_vault_access_policy.azurerm_key_vault_access_policy2
    ]
}

resource "azurerm_key_vault_secret" "key_vault_secret2" {
  name         = var.key_vault_secret_redis_connection_string_name
  value        = azurerm_redis_cache.redis.primary_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id


   depends_on = [
    azurerm_key_vault_access_policy.azurerm_key_vault_access_policy2
    ]
}
