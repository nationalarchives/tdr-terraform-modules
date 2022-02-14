variable "name" {}
variable "protocol" {
  default = "HTTP"
}
variable "body_template" {}
variable "environment" {}
variable "common_tags" {}
variable "log_format" {
  default = "{\"requestId\":\"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"requestTime\":\"$context.requestTime\", \"httpMethod\":\"$context.httpMethod\",\"routeKey\":\"$context.routeKey\", \"status\":\"$context.status\",\"protocol\":\"$context.protocol\", \"responseLength\":\"$context.responseLength\" }"
}