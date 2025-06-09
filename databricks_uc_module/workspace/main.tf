terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      version = "1.82.0"
    }
  }
}

data "databricks_spark_version" "LatestLts" {
  long_term_support = true
  latest            = true
}

data "databricks_node_type" "NodeType" {
  category      = "General Purpose"
  min_memory_gb = 16
  min_cores     = 4
  min_gpus      = 0
}

data "databricks_cluster_policy" "Shared" {
  name = "Shared Compute"
}

resource "databricks_cluster" "SharedCluster" {
  cluster_name            = "dc-shared"
  spark_version           = data.databricks_spark_version.LatestLts.id
  node_type_id            = data.databricks_node_type.NodeType.id
  autotermination_minutes = 30
  runtime_engine          = "STANDARD"
  policy_id               = data.databricks_cluster_policy.Shared.id
  data_security_mode      = "USER_ISOLATION"
  is_pinned               = true

  autoscale {
    min_workers = 2
    max_workers = 8
  }
}

resource "databricks_permission_assignment" "permission_assigmnet_devops" {
  principal_id = var.devops_group_id
  permissions  = ["ADMIN"]
}

resource "databricks_permission_assignment" "permission_assigmnet_admins" {
  count        = length(var.admin_groups_ids)
  principal_id = var.admin_groups_ids[count.index]
  permissions  = ["ADMIN"]
}

resource "databricks_permission_assignment" "permission_assigmnet_users" {
  count        = length(var.user_groups_ids)
  principal_id = var.user_groups_ids[count.index]
  permissions  = ["USER"]
}

// Creates a scope default scope pointing to an Azure KeyVault on the Databricks workspace.
resource "databricks_secret_scope" "KeyVaultScope" {
  name     = var.key_vault_name
  keyvault_metadata {
    resource_id = var.key_vault_id
    dns_name    = var.key_vault_uri
  }
}

// Sets the Access Control List for the Key Vault scope, granting read access to the users group.
resource "databricks_secret_acl" "KeyVaultACL" {
  principal  = "users"
  permission = "READ"
  scope      = databricks_secret_scope.KeyVaultScope.name
}