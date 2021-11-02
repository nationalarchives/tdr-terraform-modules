variable "common_tags" {}
variable "private_subnets" {}
variable "environment" {}
variable "database_availability_zones" {}
variable "database_name" {}
variable "admin_username" {}
variable "kms_key_id" {}
variable "security_group_ids" {}
variable "engine" {
  default = "aurora-postgresql"
}
variable "engine_version" {
  default = "11.9"
}
variable "instance_class" {
  default = "db.t3.medium"
}
variable "cloudwatch_log_exports" {
  default = ["postgresql"]
}
variable "instance_count" {
  default = 2
}
