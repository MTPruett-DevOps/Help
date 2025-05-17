# Terraform Module: Standardized Tags

This Terraform module generates a consistent set of resource tags based on standard input variables. It’s designed to promote tagging best practices across your infrastructure deployments.

---

## ✅ Purpose

Use this module to generate a standardized tag object for Azure resources, helping with:

- Governance and auditing  
- Cost allocation  
- Environment-specific tracking  
- Change traceability  

---

## 📥 Inputs

| Name               | Type   | Description                                   |
|--------------------|--------|-----------------------------------------------|
| `ChangeRequestID`  | string | Change request number (for traceability).     |
| `DepartmentNumber` | string | Department or cost center identifier.         |
| `Environment`      | string | Target environment (e.g., `dev`, `prod`).     |
| `Project`          | string | Azure DevOps project name.                    |
| `AssetName`        | string | Application or service name.                  |
| `DeployedBy`       | string | Who or what deployed the infrastructure.      |

---

## 📤 Output

| Name   | Description                          |
|--------|--------------------------------------|
| `tags` | A map of standardized resource tags. |

### Example Output

```hcl
tags = {
  ChangeRequestID  = "CHG123456"
  DepartmentNumber = "Dept001"
  Environment      = "prod"
  Project          = "cloud-platform"
  AssetName        = "Common Platform"
  DeployedBy       = "terraform-pipeline"
}