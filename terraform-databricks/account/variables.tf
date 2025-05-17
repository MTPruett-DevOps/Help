variable admin_groups {
  description = "Admin group for granting privileges"
  type        = list(string)
  default     = []
}
variable metastore_id {
  description = "Name of the metastore"
  type        = string
}
variable resource_group_name {
  description = "Name of the Azure resource group"
  type        = string
}
variable user_groups {
  description = "User group for granting privileges"
  type        = list(string)
  default     = []
}
variable workspace_id {
  description = "ID of the Databricks workspace"
  type        = string
}