variable "common_tags" {}
variable "service_name" {}
variable "vpc_id" {}

variable "policy" {
  description = "Optional Policy to attach to the endpoint"
  default     = null
}
