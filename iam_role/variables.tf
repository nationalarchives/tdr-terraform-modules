variable "assume_role_policy" {}

variable "name" {}

variable "policy_attachments" {
  description = "A list of policy arns to attach to the role"
  type        = map(string)
}

variable "common_tags" {}
