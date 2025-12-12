variable "aws_account_level" {
  description = "set to true if configuring at the AWS account level"
  default     = false
}

variable "support_group" {
  description = "group giving permissions to manage support calls with AWS"
  default     = "support"
}

variable "security_audit" {
  description = "set to true if configuring for security audit"
  default     = false
}

variable "security_audit_group" {
  description = "group giving 'read only' and 'security audit' permissions"
  default     = "security-audit"
}

variable "environment" {
}
