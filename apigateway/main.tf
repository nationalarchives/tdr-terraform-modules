resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
  body = var.api_definition
  tags = var.common_tags
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_cloudwatch_log_group.logging]

}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.environment
}

resource "aws_cloudwatch_log_group" "logging" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${var.environment}"
  retention_in_days = var.cloudwatch_log_retention_in_days
}

