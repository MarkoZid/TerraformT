terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.0.0"

    }
  }

 
}
//fneifneifnikdwdwzid
//majkati

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}

}

data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "marathon" {
  name     = "TeraMaraton"
  location = "East US"
}



# resource "azurerm_storage_account" "storageacc" {
#   name                     = "storagebackend1233"
#   resource_group_name      = azurerm_resource_group.marathon.name
#   location                 = azurerm_resource_group.marathon.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_container" "storage_comtainer" {
#   name                  = "tfstate"
#   storage_account_name  = azurerm_storage_account.storageacc.name
#   container_access_type = "container" # Set the access type (e.g., private, blob, container)
# }

resource "azurerm_service_plan" "marathon_service_plan" {
  name                = "zidar_service_plan"
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_resource_group.marathon.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}
resource "azurerm_windows_web_app" "marathon_api" {
  name                = "marathon-apizid"
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    application_stack {

      current_stack  = "dotnet"
      dotnet_version = "v7.0"

    }

  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_mssql_server.mssql_server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True"
  }

  connection_string {
    name  = "Redis"
    type  = "RedisCache"
    value = azurerm_redis_cache.redis.primary_connection_string
  }

}

resource "azurerm_windows_web_app" "marathon_client" {
  name                = "marathon-clientzid"
  resource_group_name = azurerm_resource_group.marathon.name
  location            = azurerm_service_plan.marathon_service_plan.location
  service_plan_id     = azurerm_service_plan.marathon_service_plan.id

  site_config {
    application_stack {
      current_stack = "node"
      node_version  = "~18"
    }
  }

  app_settings = {
    "DATABASE_CONNECTION_STRING" = "Server=tcp:${azurerm_mssql_server.mssql_server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True",
    "REDIS_CONNECTION_STRING"    = "redis://${azurerm_redis_cache.redis.hostname}.redis.cache.windows.net:${azurerm_redis_cache.redis.ssl_port}?ssl=true&sslverify=false"

  }
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = "sql-serverzid"
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
  name      = "mssql-dbzid"
  server_id = azurerm_mssql_server.mssql_server.id
  
  sku_name = "Basic"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }

}

resource "azurerm_mssql_firewall_rule" "dbfirewall" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}



resource "azurerm_redis_cache" "redis" {
  name                = "redis-cachezid"
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
  name                = "redisFirewallzid"
  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = azurerm_resource_group.marathon.name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}

resource "azurerm_key_vault" "key_vault" {
  name                     = "keyvault12656706034"
  location                 = azurerm_resource_group.marathon.location
  resource_group_name      = azurerm_resource_group.marathon.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false

  sku_name = "standard"
}

data "azuread_service_principal" "terraZid" {
  display_name = "ZidarTerraform2"
}

resource "azurerm_key_vault_access_policy" "terraZid_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.terraZid.object_id

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

resource "azurerm_key_vault_secret" "key_vault_secret1" {
  name         = "default-connection-string"
  //value        = "Server=tcp:${azurerm_mssql_server.mssql_server.name},1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True"
  value     = "Server=tcp:${azurerm_mssql_server.mssql_server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login}@${azurerm_mssql_server.mssql_server.name};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "key_vault_secret2" {
  name         = "redis-connection-string"
  value        = azurerm_redis_cache.redis.primary_connection_string
  key_vault_id = azurerm_key_vault.key_vault.id
}





# output "sql_connection_string" {
#   value     = "Server=tcp:${azurerm_mssql_server.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=True;Encrypt=True"
#   sensitive = true
# }

# output "redis_connection_string" {

#   value     = azurerm_redis_cache.redis.primary_connection_string
#   sensitive = true
# }


