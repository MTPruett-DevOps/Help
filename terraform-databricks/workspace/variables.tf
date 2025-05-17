variable environment {
  description = "Environment (e.g., dev, prod)"
  type        = string
}
variable admin_groups_ids {
  description = "List of admin group IDs"
  type        = list(string)
  default     = []
}
variable user_groups_ids {
  description = "List of user group IDs"
  type        = list(string)
  default     = []
}