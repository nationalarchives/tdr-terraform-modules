variable "alb_target_group_arn" {
  default = ""
}
variable "cluster_name" {}
variable "common_tags" {}
variable "compatibilities" {
  default = ["FARGATE"]
}
variable "container_definition" {}
variable "container_name" {}
variable "cpu" {}
variable "desired_count" {
  default = 1
}
variable "environment" {}
variable "execution_role" {}
variable "health_check_grace_period" {
  default = "360"
}
variable "load_balancer_container_port" {
  default = ""
}
variable "memory" {}
variable "private_subnets" {}
variable "security_groups" {}
variable "service_name" {
  default = ""
}
variable "task_family_name" {}
variable "task_role" {}
