output "api_url" {
  value = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.region}.amazonaws.com/${var.environment}"
}