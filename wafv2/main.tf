# Block blacklisted IPs
# Block access to any admin url unless in whitelist
# Block access to anyone not in the UK unless in whitelist
# Rate limits all traffic unless from private link / local subnet
# Apply AWS managed rules 

locals {
  waf_name = format("%s-%s-%s-waf", var.project, var.function, var.environment)
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = format("aws-waf-logs-%s", local.waf_name)
  tags              = var.common_tags
  retention_in_days = var.log_retention_period
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.waf.arn
}

resource "aws_wafv2_ip_set" "whitelist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-whitelist"
  addresses          = var.whitelist_ips
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "Access to all parts of the apps including admin"
}

resource "aws_wafv2_ip_set" "blacklist_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-blacklist"
  addresses          = var.blacklist_ips
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "Block ips"
}

resource "aws_wafv2_ip_set" "dont_rate_control_ips" {
  name               = "${var.project}-${var.function}-${var.environment}-dont-rate-control"
  addresses          = var.dont_rate_control_ips
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  description        = "IPs that are not subject to rate controls"
}

resource "aws_wafv2_web_acl" "waf" {
  name  = local.waf_name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf"
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
      metric_name                = "waf-block-in-blacklist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block_admin_urls_unless_in_whitelist"
    priority = 20
    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "admin"

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
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.whitelist_ips.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-admin-urls-unless-in-whitelist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block_not_in_GB"
    priority = 30
    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          not_statement {
            statement {
              geo_match_statement {
                country_codes = ["GB"]
              }
            }
          }
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
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-block-not-in-GB"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate_control"
    priority = 40
    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "IP"
        evaluation_window_sec = var.rate_limit_evaluation_window
        limit                 = var.rate_limit

        scope_down_statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.dont_rate_control_ips.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rate-control"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 50
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 51
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 52
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }


  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 53

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesUnixRuleSet"
    priority = 54

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesUnixRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 55

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
}

resource "aws_wafv2_web_acl_association" "association" {
  count        = length(var.associated_resources)
  resource_arn = var.associated_resources[count.index]
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
