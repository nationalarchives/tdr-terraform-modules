variable "vpc_id" {}

variable "common_tags" {}

variable "ingress_rules" {}

variable "name" {
  description = "The name of the network ACL. This is added to the tags"
}

variable "subnet_ids" {}
