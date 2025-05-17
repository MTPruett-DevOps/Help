output DatabricksWorkspaceId {
  value = azurerm_databricks_workspace.DatabricksWorkspace.workspace_id
}
output DatabricksWorkspaceName {
  value = azurerm_databricks_workspace.DatabricksWorkspace.name
}
output DatabricksWorkspaceURL {
  value = azurerm_databricks_workspace.DatabricksWorkspace.workspace_url
}
output DatabricksResourceID {
  value = azurerm_databricks_workspace.DatabricksWorkspace.id
}
output ResourceGroupName {
  value = azurerm_resource_group.ResourceGroup.name
}
output storage_account_name {
  value = azurerm_storage_account.StorageAccount.name
}