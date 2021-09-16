resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}

resource "aws_cloudfront_origin_request_policy" "request_policy" {
  name = "s3-multipart-upload"
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "access-control-request-headers", "access-control-request-method"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
  cookies_config {
    cookie_behavior = "none"
  }
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "cloudfront_s3_distribution" {
  aliases = [var.alias_domain_name]
  enabled = true
  logging_config {
    bucket = var.logging_bucket_regional_domain_name
  }
  default_cache_behavior {
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    target_origin_id         = local.origin_id
    viewer_protocol_policy   = "https-only"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.request_policy.id
    trusted_key_groups       = [aws_cloudfront_key_group.cookie_signing_key_group.id]
  }
  origin {
    domain_name = var.s3_regional_domain_name
    origin_id   = local.origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    acm_certificate_arn      = var.certificate_arn
  }
}

resource "aws_cloudfront_public_key" "cookie_signing_key" {
  comment     = "Public key for signed cookies"
  encoded_key = data.aws_ssm_parameter.public_key.value
  name        = "tdr-signed-cookie-key-${var.environment}"
}

resource "aws_cloudfront_key_group" "cookie_signing_key_group" {
  comment = "Key group for the signed cookie key"
  items   = [aws_cloudfront_public_key.cookie_signing_key.id]
  name    = "tdr-signed-cookie-group-${var.environment}"
}
