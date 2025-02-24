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

variable "aws_backup_account_id" {
  description = "AWS account id for the central backup"
}
