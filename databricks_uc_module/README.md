
# Databricks Unity Catalog Terraform Module

This Terraform module provisions Databricks Unity Catalog resources in a modular and reusable way.

---

## 📚 Overview

The module is composed of three internal submodules:

- `account`: Gets the group IDs of admin groups and user groups
- `workspace`: Assigns the metastore to a workspace and enables required features
- `unity_catalog`: Provisions Unity Catalog objects (catalogs, schemas, external locations)

---

## 🚀 Usage

The module uses three child modules internally:

### 1. Account Module
Gets group IDs.

```hcl
module "account" {
  source = "./modules/account"

  providers = {
    databricks = databricks.account
  }

  account_id              = var.account_id
  region                  = var.region
  storage_account_name    = var.storage_account_name
  container_name          = var.container_name
  resource_group_name     = var.resource_group_name
  metastore_name          = var.metastore_name
  storage_credential_name = var.storage_credential_name
}
```

### 2. Workspace Module
Assigns the metastore to a workspace and configures identity federation.

```hcl
module "workspace" {
  source = "./modules/workspace"

  providers = {
    databricks = databricks.workspace
  }

  workspace_id   = var.workspace_id
  workspace_url  = var.workspace_url
  metastore_id   = module.account.metastore_id
  region         = var.region
}
```

### 3. Unity Catalog Module
Deploys catalogs, schemas, and external locations in the workspace.

```hcl
module "unity_catalog" {
  source = "./modules/unity_catalog"

  providers = {
    databricks = databricks.workspace
  }

  metastore_id           = module.account.metastore_id
  storage_credential_id  = module.account.storage_credential_id
  external_location_name = var.external_location_name
  external_location_path = var.external_location_path
  catalogs               = var.catalogs
  schemas                = var.schemas
}
```

---

## 📊 Providers

This module requires **two separate Databricks providers** to authenticate at different levels:

### 1. `databricks.account`
Used for **account-level** operations like getting group IDs. This provider must be configured with an account-level id.

```hcl
provider "databricks" {
  alias                       = "account"
  host                        = "https://accounts.azuredatabricks.net"
  azure_workspace_resource_id = var.databricks_workspace.name
  account_id                  = var.account_id
}
```

### 2. `databricks.workspace`
Used for **workspace-level** operations like assigning the metastore, granting permissions, and creating Unity Catalog objects.

```hcl
provider "databricks" {
  alias                       = "workspace"
  host                        = var.databricks_workspace.url
  azure_workspace_resource_id = var.databricks_workspace.resource_id
}
```

Each submodule uses the appropriate provider based on the level of resource configuration required.

---

## ⚖️ Inputs

| Name                     | Type     | Description                           |
|--------------------------|----------|---------------------------------------|
| `account_id`            | string   | Databricks account ID                 |
| `region`                | string   | Region (e.g., "eastus")               |
| `workspace_id`          | string   | Target Databricks workspace ID        |
| `workspace_url`         | string   | Workspace URL                         |
| `metastore_name`        | string   | Name of the metastore                 |
| `storage_account_name`  | string   | Azure storage account                 |
| `container_name`        | string   | Storage container for metastore data |
| `resource_group_name`   | string   | Azure resource group name             |
| `storage_credential_name` | string | Name for the UC storage credential    |
| `external_location_name` | string  | Name of the external location         |
| `external_location_path` | string  | Path to the external location         |
| `catalogs`              | list     | List of catalog names                 |
| `schemas`               | list     | List of schema names                  |

---

## 📊 Outputs

| Name                     | Description                             |
|--------------------------|-----------------------------------------|
| `catalog_name`           | Name of the Unity Catalog                |
| `catalog_name_external`  | Name of the Federated Unity Catalog      |
| `admins`                 | List of admin group names                |
| `users`                  | List of user group names                 |
| `owners`                 | Name of the owner group                  |

---

## 🌐 Resources Used

- `databricks_metastore`
- `databricks_storage_credential`
- `databricks_metastore_assignment`
- `databricks_workspace_conf`
- `databricks_external_location`
- `databricks_catalog`
- `databricks_schema`

---

## 🎓 Requirements

- Terraform CLI
- Configured Databricks provider (both account and workspace levels)
- Azure Blob Storage setup

---

## 📝 Notes

- This module does not create or manage workspace or storage infrastructure
