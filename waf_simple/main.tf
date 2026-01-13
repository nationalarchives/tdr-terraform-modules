# Simple WAF only permits those on the whitelist
# Rate limits all traffic

locals {
  waf_name = format("%s-%s-%s-waf-simple", var.project, var.function, var.environment)
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = format("aws-waf-logs-%s", local.waf_name)
  tags              = var.common_tags
  retention_in_days = var.log_retention_period
}

resource "aws_wafv2_web_acl_logging_configuration" "simple_waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.simple_waf.arn
}

resource "aws_wafv2_ip_set" "whitelist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-whitelist"
  addresses          = var.whitelist_ips
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "Allowed IPs"
}

resource "aws_wafv2_web_acl" "simple_waf" {
  name  = local.waf_name
  scope = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "block_not_in_whitelist"
    priority = 10
    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.whitelist_ips.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-simple-block-not-in-whitelist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate_control"
    priority = 20
    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "IP"
        evaluation_window_sec = var.rate_limit_evaluation_window
        limit                 = var.rate_limit
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-simple-rate-control"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "waf-simple"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

resource "aws_wafv2_web_acl_association" "association" {
  count        = length(var.associated_resources)
  resource_arn = var.associated_resources[count.index]
  web_acl_arn  = aws_wafv2_web_acl.simple_waf.arn
}
