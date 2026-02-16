variable "api_name" {}

variable "protocol" {
  default = "HTTP"
}

variable "body_template" {}

variable "environment" {}

variable "common_tags" {}

variable "log_format" {
  default = "{\"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
}

variable "cloudwatch_log_retention_in_days" {
  description = "Cloudwatch log retention period in days (0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653)"
  default     = 30
}
