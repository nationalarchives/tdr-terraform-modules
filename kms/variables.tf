variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "key_policy" {
  description = "key policy within templates folder"
  default     = "root_access"
}

variable "policy_variables" {
  default = {}
  type    = map(string)
}

variable "aws_backup_service_role_arn" {
  description = "AWS service role for the central backup"
  default     = ""
}

variable "aws_backup_local_role_arn" {
  description = "Local account role for the central backup"
  default     = ""
}

variable "transfer_service_ecs_task_role_arn" {
  description = "Transfer Service ECS task role arn"
  default     = ""
}
