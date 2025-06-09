terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.82.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "databricks_metastore_assignment" "metastore_assignment" {
  workspace_id = var.workspace_id
  metastore_id = var.metastore_id
}

data "databricks_group" "devops_group" {
  display_name = "DevOps"
  external_id  = "8edc101e-7511-4202-bdea-0c5aece985c7"
}

data "databricks_group" "admin_groups" {
  for_each = length(var.admin_groups) > 0 ? toset(var.admin_groups) : toset([])
  display_name = each.key
}

data "databricks_group" "user_groups" {
  for_each = length(var.user_groups) > 0 ? toset(var.user_groups) : toset([])
  display_name = each.key
}

data "databricks_service_principal" "service_principal" {
  application_id = data.azurerm_client_config.current.client_id
}

resource "databricks_group" "owners" {
  display_name = "${var.asset_name}_owners_${var.environment}"
}

resource "databricks_group_member" "owners_members_devops" {
  group_id = databricks_group.owners.id
  member_id = data.databricks_group.devops_group.id
}

resource "databricks_group_member" "owners_members_admins" {
  for_each  = data.databricks_group.admin_groups
  group_id  = databricks_group.owners.id
  member_id = each.value.id
}

resource "databricks_group_member" "owners_members_this" {
  group_id  = databricks_group.owners.id
  member_id = data.databricks_service_principal.service_principal.id
} 