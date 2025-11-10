variable "environment_name" {
  description = "Environment name suffix for resources"
  type        = string
}

variable "tags" {
  description = "Tags to set"
  type        = map(any)
  default     = {}
}

variable "vpc_id" {
  description = "VPC to attach firewall to"
  type        = string
}

variable "whitelist_domains" {
  description = "List of domains to allow"
  type        = list(string)
}

variable "alert_only" {
  description = "Set action to ALERT (not BLOCK) if set"
  type        = bool
  default     = false
}
