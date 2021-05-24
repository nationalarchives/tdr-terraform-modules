variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "environment_full_name" {
  description = "full environment name, e.g. staging"
}

variable "domain" {
  description = "domain, e.g. example.com"
  default     = "nationalarchives.gov.uk"
}

variable "ns_ttl" {
  description = "time to live for name servers"
  default     = "172800"
}

variable "manual_creation" {
  description = "DNS zone created manually and imported to Terraform state"
  default     = false
}

variable "alb_dns_name" {
  description = "The DNS name for the target load balancer"
  default     = ""
}

variable "alb_zone_id" {
  description = "The zone for the target load balancer"
  default     = ""
}

variable "a_record_name" {
  description = "The name to use for the A record"
  default     = ""
}
