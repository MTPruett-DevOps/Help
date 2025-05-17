variable account_id {
  description = "The account ID of the Databricks workspace"
  type        = string
}
variable admin_groups {
  description = "The admin groups for the Databricks workspace"
  type        = list(string)
}
variable tenant_id {
  description = "The ARM tenant ID for the Databricks workspace"
  type        = string
}
variable client_secret_sql {
  description = "The client secret for SQL authentication"
  type        = string
}
variable databricks_sku {
  description = "The SKU of the Databricks workspace"
  type        = string
}
variable department_number {
  description = "The department number"
  type        = string
}
variable deployed_by { 
  description = "The name of the person who deployed the asset"
  type        = string
}
variable environment {
  description = "The environment in which the asset is deployed"
  type        = string
}
variable jdbcDatabase {
  description = "The JDBC database name"
  type        = string
}
variable jdbcHostName {
  description = "The JDBC host"
  type        = string
}
variable jdbcPort {
  description = "The JDBC port"
  type        = string
}
variable location {
  description = "The location where the asset is deployed"
  type        = string
}
variable metastore_id {
  description = "The ID of the metastore"
  type        = string
}
variable project {
  description = "The name of the project"
  type        = string
}
variable team_name {
  description = "The name of the asset"
  type        = string
}
variable user_groups {
  description = "The user groups for the Databricks workspace"
  type        = list(string)
}