variable "tags" {}
variable "step_function_name" {}
variable "definition" {}
variable "policy" {
  description = "A policy in json format to be attached to the step function role"
}
variable "environment" {}
variable "project" {}
