resource "aws_wafv2_ip_set" "whitelist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-whitelist"
  addresses          = var.whitelist_ips
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "Allowed IPs"
}

resource "aws_wafv2_web_acl" "simple_acl" {
  name  = "${var.project}-${var.function}-${var.environment}-simple"
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
      sampled_requests_enabled   = false
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
        evaluation_window_sec = 60
        limit                 = 10
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-simple-rate-control"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "waf-simple"
    sampled_requests_enabled   = false
  }

  tags = var.common_tags
}

resource "aws_wafv2_web_acl_association" "association" {
  count        = length(var.associated_resources)
  resource_arn = var.associated_resources[count.index]
  web_acl_arn  = aws_wafv2_web_acl.simple_acl.arn
}

# resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
#   log_destination_configs = var.log_destinations
#   resource_arn            = aws_wafv2_web_acl.acl.arn
# }
