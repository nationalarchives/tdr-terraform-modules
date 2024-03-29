resource "aws_s3_bucket" "log_bucket" {
  count         = var.access_logs == true && var.apply_resource == true ? 1 : 0
  acl           = "log-delivery-write"
  bucket        = "${local.bucket_name}-logs"
  force_destroy = var.force_destroy

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${local.bucket_name}-logs" }
    )
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = local.s3_bucket_id

  rule {
    bucket_key_enabled = var.bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id == "" ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_id == "" ? null : var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  count                   = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket                  = aws_s3_bucket.log_bucket.*.id[0]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "log_bucket" {
  count      = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket     = aws_s3_bucket.log_bucket.*.id[0]
  policy     = templatefile("./tdr-terraform-modules/s3/templates/secure_transport.json.tpl", { bucket_name = aws_s3_bucket.log_bucket.*.id[0] })
  depends_on = [aws_s3_bucket_public_access_block.log_bucket]
}

resource "aws_s3_bucket_notification" "log_bucket_notification" {
  count  = var.access_logs == true && var.apply_resource == true && var.log_data_sns_notification ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.*.id[0]

  topic {
    topic_arn = local.log_data_sns_topic_arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_s3_bucket_policy.log_bucket]
}

resource "aws_s3_bucket" "bucket" {
  count         = var.apply_resource == true ? 1 : 0
  bucket        = local.bucket_name
  acl           = length(var.canonical_user_grants) == 0 ? var.acl : null
  force_destroy = var.force_destroy

  dynamic "grant" {
    for_each = var.canonical_user_grants
    content {
      permissions = grant.value.permissions
      type        = "CanonicalUser"
      id          = grant.value.id
    }
  }

  versioning {
    enabled = var.versioning
  }

  dynamic "lifecycle_rule" {
    for_each = var.abort_incomplete_uploads == true ? ["include_block"] : []
    content {
      id                                     = "abort-incomplete-uploads"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7
      expiration {
        days                         = 0
        expired_object_delete_marker = false
      }
    }
  }

  dynamic "logging" {
    for_each = var.access_logs == true ? ["include_block"] : []
    content {
      target_bucket = aws_s3_bucket.log_bucket.*.id[0]
      target_prefix = "${local.bucket_name}/${data.aws_caller_identity.current.account_id}/"
    }
  }

  dynamic "cors_rule" {
    for_each = length(var.cors_urls) > 0 ? ["include-cors"] : []
    content {
      allowed_headers = ["*"]
      allowed_methods = ["PUT", "POST", "GET"]
      allowed_origins = var.cors_urls
      expose_headers  = ["ETag", "x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
      max_age_seconds = 3000
    }
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = local.bucket_name }
    )
  )
}

resource "aws_s3_bucket_policy" "bucket" {
  count  = var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]
  policy = local.environment == "mgmt" && contains(["log-data", "lambda_update"], var.bucket_policy) ? templatefile("./tdr-terraform-modules/s3/templates/${var.bucket_policy}.json.tpl",
    {
      bucket_name        = aws_s3_bucket.bucket.*.id[0],
      account_id         = data.aws_caller_identity.current.account_id,
      external_account_1 = data.aws_ssm_parameter.intg_account_number.*.value[0],
      external_account_2 = data.aws_ssm_parameter.staging_account_number.*.value[0],
      external_account_3 = data.aws_ssm_parameter.prod_account_number.*.value[0]
    }) : templatefile("./tdr-terraform-modules/s3/templates/${var.bucket_policy}.json.tpl",
    {
      bucket_name                  = aws_s3_bucket.bucket.*.id[0],
      aws_elb_account              = data.aws_ssm_parameter.aws_elb_account_number.value,
      cloudfront_oai               = var.cloudfront_oai,
      account_id                   = data.aws_caller_identity.current.account_id,
      environment                  = local.environment, title_environment = title(local.environment),
      read_access_roles            = var.read_access_role_arns,
      cloudfront_distribution_arns = jsonencode(var.cloudfront_distribution_arns)
  })
  depends_on = [aws_s3_bucket_public_access_block.bucket]
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  count                   = var.apply_resource == true ? 1 : 0
  bucket                  = aws_s3_bucket.bucket.*.id[0]
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.apply_resource == true && var.sns_notification && var.sns_topic_arn != "" ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]

  topic {
    topic_arn = var.sns_topic_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_notification" "bucket_lambda_invocation" {
  count  = var.apply_resource == true && var.lambda_notification ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]
  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    lambda_function_arn = var.lambda_arn
  }
}
