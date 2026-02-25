resource "aws_apigatewayv2_api" "api" {
  name          = var.api_name
  protocol_type = var.protocol
  body          = var.body_template
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.api_name }
    )
  )
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  triggers = {
    redeployment = sha1(jsonencode(aws_apigatewayv2_api.api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  api_id = aws_apigatewayv2_api.api.id
}

resource "aws_apigatewayv2_stage" "api_stage" {
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
  api_id        = aws_apigatewayv2_api.api.id
  name          = var.environment
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log_group.arn
    format          = var.log_format
  }
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "/apigateway/${var.api_name}"
  retention_in_days = var.cloudwatch_log_retention_in_days
}
