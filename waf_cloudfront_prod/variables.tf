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

variable "allowlist_ips" {
  description = "Allowed IPs"
  type        = list(string)
}

variable "blocklist_ips" {
  description = "Blocked IPS"
  type        = list(string)
}

variable "log_retention_period_days" {
  description = "How long in days to keep logs in cloudwatch logs"
  type        = number
  default     = 30
}

variable "rate_limit" {
  description = "Default rate limit. Max requests per IP per evaluation window before blocking (10 - 2,000,000,000). Applies to all requests except the S3 upload requests, which are counted separately by rate_limit_uploads."
  type        = number
  default     = 250
}

variable "rate_limit_uploads" {
  description = "Override rate limit for S3 upload requests only, identified by a URI path starting with a UUID. Max requests per IP per evaluation window before blocking (10 - 2,000,000,000). Upload traffic needs a much higher limit than the default."
  type        = number
  default     = 40000
}

variable "rate_limit_evaluation_window_secs" {
  description = "Sliding window in seconds for rate_limit and rate_limit_uploads. Valid values are 60, 120, 300 and 600."
  type        = number
  default     = 600
}
