terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

locals {
  admin_groups = toset(concat(["DevOps"], var.admin_groups))
}

resource "databricks_metastore_assignment" "metastore_assignment" {
  workspace_id = var.workspace_id
  metastore_id = var.metastore_id
}

data "databricks_group" "devops_group" {
  display_name = "DevOps"
}

data "databricks_group" "admin_groups" {
  for_each = length(local.admin_groups) > 0 ? toset(local.admin_groups) : toset([])
  display_name = each.key
}

data "databricks_group" "user_groups" {
  for_each = length(var.user_groups) > 0 ? toset(var.user_groups) : toset([])
  display_name = each.key
}