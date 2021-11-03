variable "cluster_name" {}
variable "common_tags" {}
variable "environment" {}
variable "task_family_name" {}
variable "execution_role" {}
variable "container_definition" {}
variable "task_role" {}
variable "memory" {}
variable "cpu" {}
variable "service_name" {}
variable "security_groups" {}
variable "private_subnets" {}
variable "alb_target_group_arn" {
  default = ""
}
variable "container_name" {}
variable "load_balancer_container_port" {}
variable "compatibilities" {
  default = ["FARGATE"]
}
