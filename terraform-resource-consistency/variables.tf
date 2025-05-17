variable "ChangeRequestID" {
  description = "The ID of the change request to be updated."
  type        = string
  default     = ""
}

variable "DepartmentNumber" {
  description = "The department number associated with the change request."
  type        = string
}

variable "Project" {
  description = "The name of the Azure DevOps project."
  type        = string
  default     = ""
}

variable "AssetName" {
  description = "The name of the asset being deployed."
  type        = string
}

variable "DeployedBy" {
  description = "The name of the person or system that deployed the code."
  type        = string
}

variable "Environment" {
  description = "The environment in which the change request is being made."
  type        = string
}

variable "Region" {
  description = "The Azure region where the resources will be deployed."
  type        = string
  default     = ""
}