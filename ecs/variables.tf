variable "access_point" {
  default = {}
}

variable "alb_target_group_arn" {
  default = ""
}

variable "app_name" {
  default = ""
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "common_tags" {}

variable "ecs_task_security_group_id" {
  default = ""
}

variable "file_format_build" {
  default = false
}

variable "file_system_id" {
  default = ""
}

variable "grafana_build" {
  default = false
}

variable "consignment_export" {
  default = false
}

variable "jenkins" {
  description = "Creates the jenkins ECS service when set to true"
  default     = false
}

variable "sbt_with_postgres" {
  default = false
}

variable "grafana_database_type" {
  default = "postgres"
}

variable "project" {}

variable "vpc_private_subnet_ids" {
  default = []
}

variable "api_url" {
  default = ""
}

variable "auth_url" {
  default = ""
}

variable "clean_bucket" {
  default = ""
}

variable "output_bucket" {
  default = ""
}

variable "backend_client_secret_path" {
  default = ""
}

variable "vpc_id" {}

variable "execution_role_arn" {
  default = ""
}

variable "task_role_arn" {
  default = ""
}

variable "name" {
  description = "Name of the service. This is currently only used for the Jenkins ECS service which can either be called jenkins or jenkins-prod"
  default     = ""
}

variable "domain_name" {
  default = ""
}

variable "plugin_updates" {
  default     = false
  description = "Create the jenkins build plugin updates task definition"
}

variable "npm" {
  default     = false
  description = "Create the jenkins build npm task definition"
}
