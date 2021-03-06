variable "common_tags" {
  description = "tags used across the project"
}

variable "all_supported" {
  description = "record configuration changes for every supported regional resource"
  default     = true
}

variable "bucket_id" {}

variable "include_global_resource_types" {
  description = "record configuration changes for global resources"
  default     = false
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the bucket name"
}

variable "primary_region" {
  default = "eu-west-2"
}

variable "primary_config_recorder_id" {
  default = ""
}

variable "global_config_rule_list" {
  description = "list of global config rules without input parameters to be applied in a single region, e.g. ROOT_ACCOUNT_MFA_ENABLED"
  default     = []
}

variable "regional_config_rule_list" {
  description = "list of global config rules without input parameters to be applied in every region, e.g. INCOMING_SSH_DISABLED"
  default     = []
}