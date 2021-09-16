data "aws_ssm_parameter" "public_key" {
  name = "/${var.environment}/cloudfront/key/public"
}
