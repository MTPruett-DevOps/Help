terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.82.0"
    }
  }
}
data "azurerm_client_config" "current" {}

provider "databricks" {
  alias                       = "account"
  host                        = "https://accounts.azuredatabricks.net"
  azure_workspace_resource_id = var.databricks_workspace.name
  account_id                  = var.account_id
}

provider "databricks" {
  alias                       = "workspace"
  host                        = var.databricks_workspace.url
  azure_workspace_resource_id = var.databricks_workspace.resource_id
}

module "databricks_account" {
  source  = "./account"
  
  providers = {
    databricks = databricks.account
  }

  asset_name   = var.asset_name
  environment = var.environment
  admin_groups = var.admin_groups
  metastore_id = var.metastore_id
  user_groups  = var.user_groups
  workspace_id = var.databricks_workspace.id
}

module "databricks_workspace" {
  source  = "./workspace"
  
  providers = {
    databricks = databricks.workspace
  }

  devops_group_id  = module.databricks_account.devops_group_id
  admin_groups_ids = module.databricks_account.admin_groups_ids
  user_groups_ids  = module.databricks_account.user_groups_ids
  key_vault_name   = var.key_vault.name
  key_vault_id     = var.key_vault.id
  key_vault_uri    = var.key_vault.uri

  depends_on = [ module.databricks_account ]
}

module "unity_catalog" {
  source  = "./unity_catalog"
  
  providers = {
    databricks = databricks.workspace
  }
  devops_group     = module.databricks_account.devops_group_name
  admin_groups     = module.databricks_account.admin_groups_names
  owner_group      = module.databricks_account.owners_group_name
  asset_name       = var.asset_name
  environment      = var.environment
  jdbc_database    = var.jdbc_database
  jdbc_host_name   = var.jdbc_host_name
  jdbc_port        = var.jdbc_port
  jdbc_username    = var.jdbc_username
  jdbc_password    = var.jdbc_password
  metastore_id     = var.metastore_id
  project          = var.project
  user_groups      = module.databricks_account.user_groups_names
  workspace_url    = var.databricks_workspace.url
  access_connector = var.access_connector
  storage = var.storage

  depends_on = [ module.databricks_workspace ]
}