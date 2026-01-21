# Simple WAF only permits those on the whitelist
# Rate limits all traffic
# Apply AWSManagedRulesCommonRuleSet

data "aws_ip_ranges" "aws_eu_west_2_api_gateway" {
  regions  = ["eu-west-2"]
  services = ["api_gateway"]
}

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

resource "aws_wafv2_ip_set" "blacklist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-blacklist"
  addresses          = var.blacklist_ips
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "Blocked IPs"
}

resource "aws_wafv2_ip_set" "aws_api_gateway_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-aws-api-gateway"
  addresses          = data.aws_ip_ranges.aws_eu_west_2_api_gateway.cidr_blocks
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "AWS API Gateway CIDRs"
}


resource "aws_wafv2_web_acl" "simple_waf" {
  name  = local.waf_name
  scope = "REGIONAL"
  default_action {
    block {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-simple"
    sampled_requests_enabled   = true
  }
  tags = var.common_tags

  rule {
    name     = "block_in_blacklist"
    priority = 10
    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklist_ips.arn
      }
    }


    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-simple-block-in-blacklist"
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
  # rule {
  #   name     = "AWS-AWSManagedRulesCommonRuleSet"
  #   priority = 30
  #   override_action {
  #     none {}
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesCommonRuleSet"
  #       vendor_name = "AWS"
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
  #     sampled_requests_enabled   = true
  #   }
  # }

  rule {
    name     = "allow_in_whitelist"
    priority = 40
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
      metric_name                = "waf-simple-allow-in-whitelist"
      sampled_requests_enabled   = true
    }
  }

  # This allows keycloak token auth and /graphql if from GB
  rule {
    name     = "allow_public_urls"
    priority = 50

    action {
      allow {
      }
    }

    statement {
      and_statement {

        statement {
          regex_match_statement {
            regex_string = "^(/realms/tdr/protocol/openid-connect/(certs|userinfo|token)|/realms/tdr/.well-known/openid-configuration|/graphql)$"

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
        statement {
          geo_match_statement {
            country_codes = ["GB"]
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-simple-allow-public"
      sampled_requests_enabled   = true
    }
  }
}


resource "aws_wafv2_web_acl_association" "association" {
  count        = length(var.associated_resources)
  resource_arn = var.associated_resources[count.index]
  web_acl_arn  = aws_wafv2_web_acl.simple_waf.arn
}
