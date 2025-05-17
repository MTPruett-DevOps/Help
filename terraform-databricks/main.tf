terraform {
  backend "remote" {}
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "tagging" {
  source  = "app.terraform.io/BMI-TF/resource-consistency/bmi"
  version = "1.0.13"
  
  AssetName        = var.team_name
  DepartmentNumber = var.department_number
  DeployedBy       = var.deployed_by
  Environment      = var.environment
  Project          = var.project
}

module "naming" {
  source  = "app.terraform.io/BMI-TF/resource-consistency/bmi"
  version = "1.0.13"
  
  AssetName        = var.team_name
  DepartmentNumber = var.department_number
  DeployedBy       = var.deployed_by
  Environment      = var.environment
}

resource "azurerm_resource_group" "ResourceGroup" {
  name     = module.naming.naming.standard.resource_group.name
  location = var.location
}

resource "azurerm_storage_account" "StorageAccount" {
  name                     = "${module.naming.naming.compact.storage_account.name}02"
  resource_group_name      = azurerm_resource_group.ResourceGroup.name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  tags                     = module.tagging.tagging
}

resource "azurerm_storage_container" "StorageContainer" {
  name                  = "unity-catalog"
  storage_account_id    = azurerm_storage_account.StorageAccount.id
  container_access_type = "private"
}

data "azurerm_databricks_access_connector" "AccessConnector" {
  name                = "bmi-bricks-${var.environment}-acccess-connector-01"
  resource_group_name = "bmi-rg-${var.environment}-data-eus"
}

resource "azurerm_role_assignment" "RoleAssignment" {
  principal_id         = data.azurerm_databricks_access_connector.AccessConnector.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.StorageAccount.id
}

resource "azurerm_databricks_workspace" "DatabricksWorkspace" {
  name                = module.naming.naming.standard.databricks_workspace.name
  location            = var.location
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  sku                 = var.databricks_sku
  tags                = module.tagging.tagging
}

provider "databricks" {
  alias                       = "account"
  host                        = "https://accounts.azuredatabricks.net"
  azure_workspace_resource_id = azurerm_databricks_workspace.DatabricksWorkspace.id
  account_id                  = var.account_id
}

provider "databricks" {
  alias                       = "workspace"
  host                        = azurerm_databricks_workspace.DatabricksWorkspace.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.DatabricksWorkspace.id
}

module "databricks_account" {
  source  = "./account"
  
  providers = {
    databricks = databricks.account
  }

  admin_groups        = var.admin_groups
  metastore_id        = var.metastore_id
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  user_groups         = var.user_groups
  workspace_id        = azurerm_databricks_workspace.DatabricksWorkspace.workspace_id

  depends_on = [ azurerm_databricks_workspace.DatabricksWorkspace ]
}

module "databricks_workspace" {
  source  = "./workspace"
  
  providers = {
    databricks = databricks.workspace
  }

  environment = var.environment
  admin_groups_ids = module.databricks_account.admin_groups_ids
  user_groups_ids  = module.databricks_account.user_groups_ids

  depends_on = [ module.databricks_account ]
}

module "unity_catalog" {
  source  = "./unity_catalog"
  
  providers = {
    databricks = databricks.workspace
  }

  admin_groups_names  = module.databricks_account.admin_groups_names
  asset_name          = var.team_name
  client_secret_sql   = var.client_secret_sql
  container           = azurerm_storage_container.StorageContainer.name
  environment         = var.environment
  jdbcDatabase        = var.jdbcDatabase
  jdbcHostName        = var.jdbcHostName
  jdbcPort            = var.jdbcPort
  metastore_id        = var.metastore_id
  project             = var.project
  resource_group_name = azurerm_resource_group.ResourceGroup.name
  storage_account     = azurerm_storage_account.StorageAccount.name
  user_groups_names   = module.databricks_account.user_groups_names
  workspace_url       = azurerm_databricks_workspace.DatabricksWorkspace.workspace_url
  tenant_id           = var.tenant_id

  depends_on = [ module.databricks_workspace ]
}