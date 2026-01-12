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
    block {}
  }

  rule {
    name     = "whitelist-ips"
    priority = 10
    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelist_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-simple-whitelist-ips"
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

# resource "aws_wafv2_web_acl_association" "association" {
#   count        = length(var.alb_target_groups)
#   resource_arn = var.alb_target_groups[count.index]
#   web_acl_arn  = aws_wafv2_web_acl.acl.arn
# }

# resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
#   log_destination_configs = var.log_destinations
#   resource_arn            = aws_wafv2_web_acl.acl.arn
# }
