variable "common_tags" {
  description = "tags used across the project"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "whitelist_ips" {
  description = "Allowed IPs"
  type        = list(string)
}

variable "associated_resources" {
  description = "list of resources arns to attached WAF to"
  type        = list(string)
}

variable "log_retention_period" {
  description = "How long in days to keep logs in cloudwatch logs"
  type        = number
  default     = 30
}

variable "rate_limit" {
  description = "The maximum number of requests to allow during the specified time window between 2,000,000,000"
  type        = number
  default     = 100
}

variable "rate_limit_evaluation_window" {
  description = "The amount of time to use for request counts valid values are in seconds (60 120 300 600)"
  type        = number
  default     = 300
}
