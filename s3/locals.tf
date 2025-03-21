locals {
  workspace              = lower(terraform.workspace)
  environment            = local.workspace == "default" ? "mgmt" : local.workspace
  standard_bucket_name   = "${var.project}-${var.function}-${local.environment}"
  global_bucket_name     = "${var.project}-${var.function}"
  bucket_name            = var.environment_suffix == true ? local.standard_bucket_name : local.global_bucket_name
  log_data_sns_topic_arn = var.log_data_sns_topic_arn == "" ? "arn:aws:sns:${var.log_data_sns_topic_region}:${data.aws_caller_identity.current.account_id}:${var.project}-logs-${local.environment}" : var.log_data_sns_topic_arn
  s3_bucket_tags         = merge(var.common_tags, var.s3_bucket_additional_tags)
  s3_log_bucket_tags     = merge(var.common_tags, var.s3_logs_bucket_additional_tags)
}

locals {
  s3_bucket_id                   = var.apply_resource == true ? aws_s3_bucket.bucket.*.id[0] : ""
  s3_bucket_arn                  = var.apply_resource == true ? aws_s3_bucket.bucket.*.arn[0] : ""
  s3_bucket_domain_name          = var.apply_resource == true ? aws_s3_bucket.bucket.*.bucket_domain_name[0] : ""
  s3_bucket_regional_domain_name = var.apply_resource == true ? aws_s3_bucket.bucket.*.bucket_regional_domain_name[0] : ""
}