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
