output "catalog_name" {
  description = "Name of the Unity Catalog"
  value       = module.unity_catalog.catalog_name
}
output "catalog_name_external" {
  description = "Name of the Federated Unity Catalog"
  value       = module.unity_catalog.catalog_name_external
}
output "admins" {
  description = "List of admin group names"
  value       = module.databricks_account.admin_groups_names
}
output "users" {
  description = "List of user group names"
  value       = module.databricks_account.user_groups_names
}
output "owners" {
  description = "Name of the owner group"
  value       = module.databricks_account.owners_group_name
}