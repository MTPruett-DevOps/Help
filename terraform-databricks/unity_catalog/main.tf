terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

locals {
  privileges_admins = {
    catalog = [
      "APPLY_TAG","CREATE_SCHEMA","MANAGE","USE_CATALOG","CREATE_VOLUME","EXECUTE","MODIFY","REFRESH","SELECT","READ_VOLUME","WRITE_VOLUME","USE_SCHEMA"
    ]
    catalog_external = [
      "APPLY_TAG","BROWSE","MANAGE","USE_CATALOG","SELECT","USE_SCHEMA"
    ]
    connection = [
      "MANAGE","USE_CONNECTION","CREATE_FOREIGN_CATALOG"
    ]
    location = [
      "CREATE_EXTERNAL_TABLE","CREATE_MANAGED_STORAGE","CREATE EXTERNAL VOLUME","MANAGE","READ_FILES","WRITE_FILES"
    ]
  }
  privileges_users = {
    catalog = [
      "USE_CATALOG","SELECT","USE_SCHEMA","SELECT","READ_VOLUME"
    ]
    catalog_external = [
      "BROWSE","USE_CATALOG","SELECT","USE_SCHEMA"
    ]
    connection = [
      "USE_CONNECTION"
    ]
    location = [
      "READ_FILES"
    ]
  }
}

data "azurerm_client_config" "current" {}

resource "databricks_catalog" "catalog" {
  name         = lower(var.project == ""  ? "${var.environment}_${var.asset_name}" : "${var.environment}_${var.asset_name}_${var.project}")
  metastore_id = var.metastore_id
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/${upper(var.environment)}",
    "unity",
    "bmistorage${var.environment}unity01")
  isolation_mode = "ISOLATED"
}

resource "databricks_grant" "grant_catalog_admins" {
  count      = length(var.admin_groups_names)
  catalog    = databricks_catalog.catalog.name
  principal  = var.admin_groups_names[count.index]
  privileges = local.privileges_admins.catalog
}
resource "databricks_grant" "grant_catalog_users" {
  count      = length(var.user_groups_names)
  catalog    = databricks_catalog.catalog.name
  principal  = var.user_groups_names[count.index]
  privileges = local.privileges_users.catalog
}