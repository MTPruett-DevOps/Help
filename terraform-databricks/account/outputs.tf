output devops_group_id {
  value = data.databricks_group.devops_group.id
}
output admin_groups_ids {
  value = [for group in data.databricks_group.admin_groups : group.id]
}
output admin_groups_names {
  value = [for group in data.databricks_group.admin_groups : group.display_name]
}
output user_groups_ids {
  value = [for group in data.databricks_group.user_groups : group.id]
}
output "user_groups_names" {
  value = [for group in data.databricks_group.user_groups : group.display_name]
}