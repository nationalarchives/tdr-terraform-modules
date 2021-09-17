locals {
  s3_origin_id          = "cloudfront-s3-${var.environment}"
  api_gateway_origin_id = "cloudfront-api-gateway-${var.environment}"
}
