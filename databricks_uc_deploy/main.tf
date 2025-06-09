terraform {
    cloud {
        hostname = "app.terraform.io"
        organization = "internal-platform"
        workspaces {
            name = "databricks-governed"
        }
    }
    required_providers {
        azuread = {
            source      = "hashicorp/azuread"
            version     = "3.4.0"
        }
        azurerm = {     
            source      = "hashicorp/azurerm"
            version     = "4.32.0"
        }
        databricks = {
            source      = "databricks/databricks"
            version     = "1.82.0"
        }
    }
}

module "resource_consistency" {
    source = "git::https://github.com/MTPruett-DevOps/Help//terraform-resource-consistency?ref=main"

    AssetName        = var.team_name
    DepartmentNumber = var.department_number
    DeployedBy       = var.deployed_by
    Environment      = var.environment
}

# Defining the default provider
provider "azurerm" {
    features {}
}

# Defining the provider for log analytics info (Inf Sub)
provider "azurerm" {
    alias = "infrastructure"
    features {}
    subscription_id = "00000000-1111-2222-3333-444455556666"
}

data "azurerm_client_config" "current" {}

data "azuread_group" "AZSubscriptionOwners" {
    display_name = "AZSubscriptionOwners"
}

data "azuread_group" "AdminGroups" {
    for_each = toset(var.admin_groups)
    display_name = each.value
}

data "azuread_group" "DeveloperGroups" {
    for_each = toset(var.user_groups)
    display_name = each.value
}

data "azurerm_log_analytics_workspace" "LawsWorkspace" {
    provider            = azurerm.infrastructure
    name                = var.log_analytics_workspace_name
    resource_group_name = var.log_analytics_workspace_resource_group
}

resource "azurerm_resource_group" "ResourceGroup" {
    name     = module.resource_consistency.naming.standard.resource_group.name
    location = var.location
    tags     = module.resource_consistency.tagging
}

resource "azurerm_key_vault" "KeyVault" {
    name                        = module.resource_consistency.naming.standard.key_vault.name
    location                    = var.location
    resource_group_name         = "${azurerm_resource_group.ResourceGroup.name}"  
    enabled_for_disk_encryption = true
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days  = 90
    purge_protection_enabled    = true
    sku_name                    = "premium"
    access_policy = [
        {
            application_id          = null
            object_id               = "${data.azurerm_client_config.current.object_id}"
            certificate_permissions = ["List"]
            key_permissions         = ["List"]
            secret_permissions      = ["Backup", "Delete", "Get", "List", "Recover", "Restore", "Set"]
            storage_permissions     = ["List"]
            tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
        },
        {
            application_id          = null
            object_id               = "${data.azuread_group.AZSubscriptionOwners.object_id}"
            certificate_permissions = ["List"]
            key_permissions         = ["List"]
            secret_permissions      = ["Backup", "Delete", "Get", "List", "Recover", "Restore", "Set"]
            storage_permissions     = ["List"]
            tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
        },
        {
            application_id          = null
            object_id               = "${data.azuread_group.AdminGroups[var.admin_groups[0]].object_id}"
            certificate_permissions = ["List"]
            key_permissions         = ["List"]
            secret_permissions      = ["Backup", "Delete", "Get", "List", "Recover", "Restore", "Set"]
            storage_permissions     = ["List"]
            tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
        },
        {
            application_id          = null
            object_id               = "${data.azuread_group.DeveloperGroups[var.user_groups[0]].object_id}"
            certificate_permissions = ["List"]
            key_permissions         = ["List"]
            secret_permissions      = ["Backup", "Delete", "Get", "List", "Recover", "Restore", "Set"]
            storage_permissions     = ["List"]
            tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
        },
        {
            application_id          = null
            object_id               = "${data.azuread_group.DeveloperGroups[var.user_groups[0]].object_id}"
            certificate_permissions = ["List"]
            key_permissions         = ["List"]
            secret_permissions      = ["Backup", "Delete", "Get", "List", "Recover", "Restore", "Set"]
            storage_permissions     = ["List"]
            tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
        },
        {
            application_id          = null
            object_id               = "${data.azuread_group.DeveloperGroups[var.user_groups[1]].object_id}"
            certificate_permissions = ["List"]
            key_permissions         = ["List"]
            secret_permissions      = ["Backup", "Delete", "Get", "List", "Recover", "Restore", "Set"]
            storage_permissions     = ["List"]
            tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
        }
    ]
    tags = module.resource_consistency.tagging
}

resource "azurerm_storage_account" "StorageAccount" {
    name                     = "${module.resource_consistency.naming.compact.storage_account.name}"
    resource_group_name      = azurerm_resource_group.ResourceGroup.name
    location                 = var.location
    account_tier             = "Premium"
    account_replication_type = "LRS"
    account_kind             = "BlockBlobStorage"
    is_hns_enabled           = true
    tags                     = module.resource_consistency.tagging
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
    name                = module.resource_consistency.naming.standard.databricks_workspace.name
    location            = var.location
    resource_group_name = azurerm_resource_group.ResourceGroup.name
    sku                 = var.databricks_sku
    tags                = module.resource_consistency.tagging
}

locals {
    enabled_logs = [
        "dbfs", "clusters","accounts","jobs","notebook","ssh","workspace","secrets","sqlPermissions","instancePools","sqlanalytics","genie","globalInitScripts","iamRole",
        "RemoteHistoryService","mlflowExperiment","featureStore","databrickssql","mlflowAcledArtifact","databrickssql","deltaPipelines","modelRegistry","repos"
    ]
}

resource "azurerm_monitor_diagnostic_setting" DatabricksMonitoring {
    name                       = "${azurerm_databricks_workspace.DatabricksWorkspace.name}-diagnostics"
    target_resource_id         = azurerm_databricks_workspace.DatabricksWorkspace.id
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.LawsWorkspace.id
    dynamic "enabled_log" {
      for_each = toset(local.enabled_logs)
      content {
        category = enabled_log.value
      }
    }
}

module "Databricks" {
    source  = "app.terraform.io/BMI-TF/databricks/bmi"
    version = "2.0.3"

    asset_name     = var.team_name
    account_id     = var.account_id
    metastore_id   = var.metastore_id
    jdbc_database  = var.SqlServerDatabaseName
    jdbc_host_name = var.SqlServerHostName
    jdbc_port      = var.SqlServerPort
    jdbc_username  = var.SqlServerUsername
    jdbc_password  = var.SqlServerPassword
    environment    = var.environment
    admin_groups   = var.admin_groups
    user_groups    = var.user_groups
    resource_group = "${azurerm_resource_group.ResourceGroup.name}"
    databricks_workspace = {
        name        = "${azurerm_databricks_workspace.DatabricksWorkspace.name}"
        id          = "${azurerm_databricks_workspace.DatabricksWorkspace.workspace_id}"
        resource_id = "${azurerm_databricks_workspace.DatabricksWorkspace.id}"
        url         = "${azurerm_databricks_workspace.DatabricksWorkspace.workspace_url}"
    }
    storage = {
        account_name   = "${azurerm_storage_account.StorageAccount.name}"
        container_name = "${azurerm_storage_container.StorageContainer.name}"
    }
    key_vault = {
      name = "${azurerm_key_vault.KeyVault.name}"
      id   = "${azurerm_key_vault.KeyVault.id}"
      uri  = "${azurerm_key_vault.KeyVault.vault_uri}"
    }
    access_connector = data.azurerm_databricks_access_connector.AccessConnector.name
}

resource "azurerm_data_factory" "DataFactory" {
    name                = module.resource_consistency.naming.standard.data_factory.name
    location            = var.location
    resource_group_name = azurerm_resource_group.ResourceGroup.name
    tags                = module.resource_consistency.tagging
}
