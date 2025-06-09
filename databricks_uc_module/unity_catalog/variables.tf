variable admin_groups {
  description = "List of admin group names"
  type        = list(string)
}
variable devops_group {
  description = "Name of the DevOps group"
  type        = string
}
variable owner_group {
  description = "Name of the owner group"
  type        = string
}
variable asset_name {
  description = "Name of the asset"
  type        = string
}
variable access_connector {
  description = "Name of the access connector"
  type        = string
}
variable environment {
  description = "Environment (e.g., dev, prod)"
  type        = string
}
variable jdbc_host_name {
  description = "JDBC host name"
  type        = string
}
variable jdbc_port {
  description = "JDBC port"
  type        = number
}
variable jdbc_database {
  description = "JDBC database name"
  type        = string
}
variable jdbc_username {
  description = "JDBC username"
  type        = string
}
variable jdbc_password {
  description = "JDBC password"
  type        = string
  sensitive   = true
}
variable metastore_id {
  description = "Metastore ID for the catalog"
  type        = string
}
variable project {
  description = "Project name"
  type        = string
}
variable storage {
  description = "The name of the storage account"
  type        = object({
    account_name   = string
    container_name = string
  })
}
variable user_groups {
  description = "List of user group names"
  type        = list(string)
}
variable workspace_url {
  description = "URL of the Databricks workspace"
  type        = string
}