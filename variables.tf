variable "location" {
  description = "The location where the Azure resources will be deployed."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "TeraMarathon"
}


variable "service_plan_name" {
  description = "The name of the Azure App Service plan."
  type        = string
  default     = "marathon_service_planzid"
}

variable "app_name_api" {
  description = "The name of the Azure Web App for the API."
  type        = string
  default     = "marathon-apizid"
}

variable "app_name_client" {
  description = "The name of the Azure Web App for the client."
  type        = string
  default     = "marathon-clientzid"
}

variable "sql_server_name" {
  description = "The name of the SQL Server."
  type        = string
  default     = "sql-server14zidar"
}

variable "sql_database_name" {
  description = "The name of the SQL Database."
  type        = string
  default     = "mssql-db14zid"
}

variable "redis_cache_name" {
  description = "The name of the Redis Cache."
  type        = string
  default     = "redis-cache12zid"
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
  default     = "keyvaultzid12"
}

variable "key_vault_secret_connection_string_name" {
  description = "The name of the Key Vault secret for the connection string."
  type        = string
  default     = "default-connection-string"
}

variable "key_vault_secret_redis_connection_string_name" {
  description = "The name of the Key Vault secret for the Redis connection string."
  type        = string
  default     = "redis-connection-string1"
}

variable "user_object_id" {
  description = "The object ID of the user to grant access to the Key Vault."
  type        = string
  default     = "d4fc02f0-09ff-4f8b-a337-5e569165c2ae" # You can change this default value to the actual object ID
}

variable "display_name" {
  description = "Used for the service principal"
  type        = string
  default     = "ZidarTerraform2"
}

variable "redis_name" {
  description = "Name for Redis"
  type        = string
  default     = "redisFirewall12"
}

variable "redis_firewall" {
  description = "Name for Redis Firewall"
  type        = string
  default     = "FirewallRule1"
}