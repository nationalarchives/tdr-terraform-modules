variable "admin_username" {}
variable "cloudwatch_log_exports" {
  default = ["postgresql"]
}
variable "common_tags" {}
variable "database_availability_zones" {}
variable "database_name" {}
variable "engine" {
  default = "aurora-postgresql"
}
variable "engine_version" {
  default = "11.13"
}
variable "environment" {}
variable "instance_class" {
  default = "db.t3.medium"
}
variable "instance_count" {
  default = 2
}
variable "kms_key_id" {}
variable "private_subnets" {}
variable "security_group_ids" {}
