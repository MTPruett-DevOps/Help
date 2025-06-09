#azure variables
variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}
variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, test, prod)."
  type        = string
}
variable "log_analytics_workspace_resource_group" {
  description = "The resource group where the Log Analytics workspace is located."
  type        = string
}
variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
}

#databricks variables
variable "databricks_sku" {
  description = "The SKU for the Databricks workspace."
  type        = string
}
variable "account_id" {
  description = "The Azure account ID for the Databricks workspace."
  type        = string
}
variable "metastore_id" {
  description = "The ID of the Metastore to be used with the Databricks workspace."
  type        = string
}
variable SqlServerHostName {
  description = "JDBC host name"
  type        = string
}
variable SqlServerPort {
  description = "JDBC port"
  type        = number
}
variable SqlServerDatabaseName {
  description = "JDBC database name"
  type        = string
}
variable SqlServerUsername {
  description = "JDBC username"
  type        = string
}
variable SqlServerPassword {
  description = "JDBC password"
  type        = string
  sensitive   = true
}
#project variables
variable "team_name" {
  description = "The name of the team responsible for the resources."
  type        = string
}
variable "department_number" {
  description = "The department number associated with the resources."
  type        = string
}
variable "deployed_by" {
  description = "The name of the person or team deploying the resources."
  type        = string
}
variable "admin_groups" {
  description = "List of Azure AD groups that will have admin access to the Databricks workspace."
  type        = list(string)
}
variable "user_groups" {
  description = "List of Azure AD groups that will have user access to the Databricks workspace."
  type        = list(string)
}