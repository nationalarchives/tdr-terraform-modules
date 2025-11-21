locals {
  s3_origin_id_oac      = "cloudfront-s3-oac-${var.environment}"
  api_gateway_origin_id = "cloudfront-api-gateway-${var.environment}"
}
