variable "name" {
  description = "The name of the cloudwatch log group"
}

variable "retention_in_days" {
  description = "How many days to retain logs for"
  default     = 0
}

variable "common_tags" {}
