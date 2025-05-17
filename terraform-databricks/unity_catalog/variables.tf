variable admin_groups_names {
  description = "List of admin group names"
  type        = list(string)
}
variable asset_name {
  description = "Name of the asset"
  type        = string
}
variable tenant_id {
  description = "Tenant ID for the Azure subscription"
  type        = string
}
variable client_secret_sql {
  description = "Client secret for the connection"
  type        = string
}
variable container {
  description = "Name of the container"
  type        = string
}
variable environment {
  description = "Environment (e.g., dev, prod)"
  type        = string
}
variable jdbcHostName {
  description = "JDBC host name"
  type        = string
}
variable jdbcPort {
  description = "JDBC port"
  type        = number
}
variable jdbcDatabase {
  description = "JDBC database name"
  type        = string
}
variable metastore_id {
  description = "Metastore ID for the catalog"
  type        = string
}
variable project {
  description = "Project name"
  type        = string
}
variable resource_group_name {
  description = "Name of the Azure resource group"
  type        = string
}
variable storage_account {
  description = "Name of the storage account"
  type        = string
}
variable user_groups_names {
  description = "List of user group names"
  type        = list(string)
}
variable workspace_url {
  description = "URL of the Databricks workspace"
  type        = string
}