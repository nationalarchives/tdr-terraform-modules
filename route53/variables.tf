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

variable "create_hosted_zone" {
  // The default behaviour of this module is to create the hosted zone. I don't need it so I'm adding this variable but defaulting it to true so I don't break any existing code using it.
  default = true
}

variable "hosted_zone_id" {
  default = ""
}

variable "hosted_zone_name_servers" {
  default = ""
}

variable "kms_key_arn" {
  description = "The KMS Key ARN to enable DNSSEC on the hosted zone. It is optional because not all calls to this module create the hosted zone."
  default     = ""
}

variable "vpc_id" {
  default = ""
}
