output "tagging" {
  value = merge(
    {
      AssetName        = upper(var.AssetName)
      DepartmentNumber = upper(var.DepartmentNumber)
      DeployedBy       = upper(var.DeployedBy)
    },
    var.ChangeRequestID != "" ? { ChangeRequestID = upper(var.ChangeRequestID) } : {},
    var.Project         != "" ? { Project         = upper(var.Project) } : {},
    var.Environment     != "" ? { Environment     = upper(var.Environment) } : {},
    var.Region          != "" ? { Region          = upper(var.Region) } : {}
  )
}

output "naming" {
  value = {
    standard  = module.standard
    compact   = module.compact
  }
}