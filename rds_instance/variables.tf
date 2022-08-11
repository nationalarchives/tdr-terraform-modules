variable "instance_class" {
  default = "db.t3.medium"
}

variable "database_name" {}

variable "admin_username" {}

variable "kms_key_id" {}

variable "security_group_ids" {}

variable "environment" {}

variable "private_subnets" {}

variable "common_tags" {}

variable "availability_zone" {}
