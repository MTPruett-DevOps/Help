terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.82.0"
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
    schema = [
      "APPLY_TAG","CREATE_FUNCTION","CREATE_TABLE","CREATE_VOLUME","MANAGE","USE_SCHEMA","EXECUTE","MODIFY","REFRESH","SELECT","READ_VOLUME","WRITE_VOLUME"
    ]
    volume = [
      "MANAGE","READ_VOLUME","WRITE_VOLUME"
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
    schema = [
      "USE_SCHEMA","SELECT","READ_VOLUME"
    ]
    volume = [
      "READ_VOLUME"
    ]
  }
  privileges_devops = {
    catalog = [
      "All_PRIVILEGES"
    ]
    catalog_external = [
      "All_PRIVILEGES"
    ]
    connection = [
      "All_PRIVILEGES"
    ]
    location = [
      "All_PRIVILEGES"
    ]
    schema = [
      "All_PRIVILEGES"
    ]
    volume = [
      "All_PRIVILEGES"
    ]
  }
}

resource "databricks_catalog" "catalog" {
  name         = lower(var.project == ""  ? "${var.asset_name}_${var.environment}" : "${var.asset_name}_${var.project}_${var.environment}")
  metastore_id = var.metastore_id
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/${upper(var.environment)}",
    "unity",
    "bmistorage${var.environment}unity01")
  isolation_mode = "ISOLATED"
  owner = var.owner_group
}
resource "databricks_grant" "grant_catalog_devops" {
  catalog    = databricks_catalog.catalog.name
  principal  = var.devops_group
  privileges = local.privileges_devops.catalog
}
resource "databricks_grant" "grant_catalog_admins" {
  count      = length(var.admin_groups)
  catalog    = databricks_catalog.catalog.name
  principal  = var.admin_groups[count.index]
  privileges = local.privileges_admins.catalog
}
resource "databricks_grant" "grant_catalog_users" {
  count      = length(var.user_groups)
  catalog    = databricks_catalog.catalog.name
  principal  = var.user_groups[count.index]
  privileges = local.privileges_users.catalog
}

resource "databricks_schema" "schema" {
  name         = "default_schema"
  catalog_name = databricks_catalog.catalog.name
  owner        = var.owner_group
}

resource "databricks_grant" "grant_schema_devops" {
  schema     = databricks_schema.schema.id
  principal  = var.devops_group
  privileges = local.privileges_devops.schema
}
resource "databricks_grant" "grant_schema_admins" {
  count      = length(var.admin_groups)
  schema     = databricks_schema.schema.id
  principal  = var.admin_groups[count.index]
  privileges = local.privileges_admins.schema
}
resource "databricks_grant" "grant_schema_users" {
  count      = length(var.user_groups)
  schema     = databricks_schema.schema.id
  principal  = var.user_groups[count.index]
  privileges = local.privileges_users.schema
}


resource "databricks_external_location" "external_location" {
  name            = "${var.storage.account_name}_${var.storage.container_name}"
  credential_name = var.access_connector
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.storage.container_name,
    var.storage.account_name)
  owner        = var.owner_group
}
resource "databricks_grant" "grant_external_location_devops" {
  external_location = databricks_external_location.external_location.name
  principal         = var.devops_group
  privileges        = local.privileges_devops.location
}
resource "databricks_grant" "grant_external_location_admins" {
  count              = length(var.admin_groups)
  external_location  = databricks_external_location.external_location.name
  principal          = var.admin_groups[count.index]
  privileges         = local.privileges_admins.location
}
resource "databricks_grant" "grant_external_location_users" {
  count              = length(var.user_groups)
  external_location  = databricks_external_location.external_location.name
  principal          = var.user_groups[count.index]
  privileges         = local.privileges_users.location
}

resource "databricks_volume" "volume" {
  name             = var.storage.container_name
  volume_type      = "EXTERNAL"
  catalog_name     = databricks_catalog.catalog.name
  schema_name      = databricks_schema.schema.name
  storage_location = databricks_external_location.external_location.url
  owner            = var.owner_group
}

resource "databricks_grant" "grant_volume_devops" {
  volume    = databricks_volume.volume.id
  principal = var.devops_group
  privileges = local.privileges_devops.volume
}
resource "databricks_grant" "grant_volume_admins" {
  count     = length(var.admin_groups)
  volume    = databricks_volume.volume.id
  principal = var.admin_groups[count.index]
  privileges = local.privileges_admins.volume
}
resource "databricks_grant" "grant_volume_users" {
  count     = length(var.user_groups)
  volume    = databricks_volume.volume.id
  principal = var.user_groups[count.index]
  privileges = local.privileges_users.volume
}

resource "databricks_connection" "connection" {
  name         = lower(var.project == ""  ? "${var.asset_name}_${var.environment}_sql" : "${var.asset_name}_${var.project}_${var.environment}_sql")
  connection_type = "SQLSERVER"
  options = {
    "host"     = var.jdbc_host_name
    "port"     = var.jdbc_port
    "user"     = var.jdbc_username
    "password" = var.jdbc_password
  }
  owner = var.owner_group
}
resource "databricks_grant" "grant_connection_devops" {
  foreign_connection  = databricks_connection.connection.name

  principal  = var.devops_group
  privileges = local.privileges_devops.connection
}
resource "databricks_grant" "grant_connection_admins" {
  count              = length(var.admin_groups)
  foreign_connection = databricks_connection.connection.name

  principal  = var.admin_groups[count.index]
  privileges = local.privileges_admins.connection
}
resource "databricks_grant" "grant_connection_users" {
  count              = length(var.user_groups)
  foreign_connection = databricks_connection.connection.name

  principal  = var.user_groups[count.index]
  privileges = local.privileges_users.connection
}

resource "databricks_catalog" "catalog_external" {
  provider        = databricks
  name            = lower(var.project == ""  ? "${var.asset_name}_${var.environment}_fed" : "${var.asset_name}_${var.project}_${var.environment}_fed")
  metastore_id    = var.metastore_id
  connection_name = databricks_connection.connection.name
  options = {
    database = var.jdbc_database
  }
  owner           = var.owner_group
  isolation_mode  = "ISOLATED"
}
resource "databricks_grant" "grant_catalog_external_devops" {
  catalog    = databricks_catalog.catalog_external.name
  principal  = var.devops_group
  privileges = local.privileges_devops.catalog_external
}
resource "databricks_grant" "grant_catalog_external_admins" {
  count      = length(var.admin_groups)
  catalog    = databricks_catalog.catalog_external.name
  principal  = var.admin_groups[count.index]
  privileges = local.privileges_admins.catalog_external
}
resource "databricks_grant" "grant_catalog_external_users" {
  count      = length(var.user_groups)
  catalog    = databricks_catalog.catalog_external.name
  principal  = var.user_groups[count.index]
  privileges = local.privileges_users.catalog_external
}