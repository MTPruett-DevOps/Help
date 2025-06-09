variable devops_group_id {
  description = "List of DevOps group IDs"
  type        = string
}
variable admin_groups_ids {
  description = "List of admin group IDs"
  type        = list(string)
  default     = []
}
variable user_groups_ids {
  description = "List of user group IDs"
  type        = list(string)
  default     = []
}
variable key_vault_name {
  description = "The name of the Azure Key Vault"
  type        = string
  default     = "databricks-kv"
}
variable key_vault_id {
  description = "The ID of the Azure Key Vault"
  type        = string
}
variable key_vault_uri {
  description = "The URI of the Azure Key Vault"
  type        = string
}