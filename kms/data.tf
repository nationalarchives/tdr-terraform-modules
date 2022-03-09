data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "transform_engine_retry_role_arn" {
  name = "/${var.environment}/transform_engine/retry_role_arn"
}
