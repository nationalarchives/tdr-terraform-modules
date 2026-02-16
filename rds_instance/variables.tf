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

variable "multi_az" {}

variable "ca_cert_identifier" {
  default     = "rds-ca-2019"
  description = "RDS certificate version for the instance"
}

variable "backup_retention_period" {
  default = 7
}

variable "database_version" {
  default = "14.4"
}

variable "apply_immediately" {
  default     = false
  description = "Apply modifications immediately or wait for next maintenance window"
}

variable "aws_backup_tag" {
  description = "Tag to indicate resource should be backed up"
  default     = null
}

variable "allocated_storage" {
  description = "Allocated storage for the database in GB"
  type        = number
  default     = 60
}

variable "cloudwatch_log_retention_in_days" {
  description = "Cloudwatch log retention period in days (0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653)"
  default     = 30
}
