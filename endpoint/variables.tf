variable "common_tags" {}
variable "service_name" {}
variable "vpc_id" {}
variable "policy" {
  default = null
}
variable "vpc_endpoint_type" {
  default = null
}
variable "subnet_ids" {
  description = "List of subnets to create endpoint in"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security groups to attach to endpoint"
  type        = list(string)
  default     = null
}


