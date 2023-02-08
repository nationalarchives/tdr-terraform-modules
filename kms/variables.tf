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

variable "key_usage" {
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key"
}

variable "customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports."
  default     = "SYMMETRIC_DEFAULT"
}

variable "enable_key_rotation" {
  default = true
}
