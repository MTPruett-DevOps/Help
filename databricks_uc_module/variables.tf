# azure variables
variable environment {
  description = "The environment in which the asset is deployed"
  type        = string
}
variable resource_group {
  description = "The name of the Azure resource group"
  type        = string
}

# project variables
variable asset_name {
  description = "The name of the asset"
  type        = string
}
variable project {
  description = "The name of the project"
  type        = string
  default     = ""
}

# databricks variables
variable metastore_id {
  description = "The ID of the metastore"
  type        = string
}
variable account_id {
  description = "The account ID of the Databricks workspace"
  type        = string
}
variable admin_groups {
  description = "The admin groups for the Databricks workspace"
  type        = list(string)
}
variable user_groups {
  description = "The user groups for the Databricks workspace"
  type        = list(string)
}
variable access_connector {
  description = "The name of the access connector"
  type        = string
}
variable storage {
  description = "The name of the storage account"
  type        = object({
    account_name   = string
    container_name = string
  })
}
variable jdbc_host_name {
  description = "The JDBC host name"
  type        = string
}
variable jdbc_port {
  description = "The JDBC port"
  type        = string
}
variable jdbc_database {
  description = "The JDBC database name"
  type        = string
}
variable jdbc_username {
  description = "The JDBC username"
  type        = string
}
variable jdbc_password {
  description = "The JDBC password"
  type        = string
}
variable key_vault {
  description = "The Azure Key Vault configuration"
  type = object({
    name     = string
    id       = string
    uri      = string
  })
}
variable databricks_workspace {
  description = "The Databricks workspace configuration"
  type = object({
    name        = string
    id          = string
    resource_id = string
    url         = string
  })
}