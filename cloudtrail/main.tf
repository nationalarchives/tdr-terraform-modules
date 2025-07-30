resource "aws_iam_role" "cloudtrail_role" {
  name = "${upper(var.project)}CloudTrail${title(local.environment)}"
  assume_role_policy = templatefile("./tdr-terraform-modules/cloudtrail/templates/assume_role_policy.json.tpl", {
    trail_name    = local.cloudtrail_name
    account_id    = data.aws_caller_identity.current.id
    aws_partition = data.aws_partition.current.id
    aws_region    = data.aws_region.current.region
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name   = "${upper(var.project)}Cloudwatch${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/cloudtrail/templates/cloudwatch_logs_policy.json.tpl", {})
}

resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attach" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/cloudtrail/${local.cloudtrail_prefix}"
  retention_in_days = var.cloudwatch_rentention_period
  tags              = var.common_tags
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = local.cloudtrail_name
  s3_bucket_name                = var.s3_bucket_name
  s3_key_prefix                 = local.cloudtrail_prefix
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}${var.log_stream_wildcard}"
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_key_id
  tags                          = var.common_tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }
}
