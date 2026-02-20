variable "api_definition" {
  description = "The json definition of the API"
}
variable "api_name" {}
variable "environment" {}
variable "common_tags" {}
variable "region" {
  default = "eu-west-2"
}
variable "cloudwatch_log_retention_in_days" {
  description = "Cloudwatch log retention period in days (0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653)"
  default     = 30
}
