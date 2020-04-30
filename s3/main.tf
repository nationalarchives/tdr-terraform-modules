resource "aws_s3_bucket" "log_bucket" {
  count         = var.access_logs == true && var.apply_resource == true ? 1 : 0
  acl           = "log-delivery-write"
  bucket        = "${local.bucket_name}-logs"
  force_destroy = var.force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.kms_key_id == "" ? "AES256" : "aws:kms"
        kms_master_key_id = var.kms_key_id == "" ? null : var.kms_key_id
      }
    }
  }

  versioning {
    enabled = true
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "${local.bucket_name}-logs",
    )
  )
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  count  = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.*.id[0]

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "log_bucket" {
  count  = var.access_logs == true && var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.log_bucket.*.id[0]
  policy = templatefile("./tdr-terraform-modules/s3/templates/secure_transport.json.tpl", { bucket_name = aws_s3_bucket.log_bucket.*.id[0] })
}

resource "aws_s3_bucket" "bucket" {
  count         = var.apply_resource == true ? 1 : 0
  bucket        = local.bucket_name
  acl           = var.acl
  force_destroy = var.force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = var.versioning
  }
  dynamic "lifecycle_rule" {
    for_each = var.version_lifecycle == true ? ["include_block"] : []
    content {
      id = "delete-old-versions"
      enabled = true

      noncurrent_version_expiration {
        days = 30
      }
    }
  }

  dynamic "logging" {
    for_each = var.access_logs == true ? ["include_block"] : []
    content {
      target_bucket = aws_s3_bucket.log_bucket.*.id[0]
      target_prefix = local.bucket_name
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors == true ? ["include-cors"] : []
    content {
      allowed_headers = ["*"]
      allowed_methods = ["PUT", "POST", "GET"]
      allowed_origins = [var.frontend_url]
      expose_headers  = ["ETag"]
    }
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", local.bucket_name,
    )
  )
}

resource "aws_s3_bucket_policy" "bucket" {
  count  = var.apply_resource == true ? 1 : 0
  bucket = aws_s3_bucket.bucket.*.id[0]
  policy = templatefile("./tdr-terraform-modules/s3/templates/${var.bucket_policy}.json.tpl", { bucket_name = aws_s3_bucket.bucket.*.id[0] })
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  count                   = var.apply_resource == true ? 1 : 0
  bucket                  = aws_s3_bucket.bucket.*.id[0]
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  depends_on              = [aws_s3_bucket_policy.bucket]
}
