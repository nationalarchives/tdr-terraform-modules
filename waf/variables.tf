variable "common_tags" {
  description = "tags used across the project"
}

variable "project" {
  description = "abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the resource name, eg. upload"
}

variable "environment" {
  description = "environment, e.g. prod"
}

variable "alb_target_groups" {
  description = "List of ALB target group ARNs for WAF rule association"
}

variable "trusted_ips" {
  description = "trusted IP addresses in csv format"
  default     = ""
}

variable "blocked_ips" {
  description = "blocked IP addresses"
  default     = ""
}

variable "restricted_uri" {
  description = "Restricted URI"
  default     = ""
}

variable "geo_match" {
  description = "Country codes in csv format"
  default     = ""
}

variable "log_destinations" {
  description = "A list of destinations to send the waf logs to"
  type        = list(string)
  default     = []
}

variable "aws_managed_rules" {
  description = "List of AWS managed rules to be applied"
  type = list(object({
    name                                     = string
    priority                                 = number
    managed_rule_group_statement_name        = string
    managed_rule_group_statement_vendor_name = string
    metric_name                              = string
  }))
  default = [
    { name = "AWS-AWSManagedRulesAmazonIpReputationList", priority = 3, managed_rule_group_statement_name = "AWSManagedRulesAmazonIpReputationList", managed_rule_group_statement_vendor_name = "AWS", metric_name = "AWS-AWSManagedRulesAmazonIpReputationList" },
    { name = "AWS-AWSManagedRulesCommonRuleSet", priority = 4, managed_rule_group_statement_name = "AWSManagedRulesCommonRuleSet", managed_rule_group_statement_vendor_name = "AWS", metric_name = "AWS-AWSManagedRulesCommonRuleSet" },
    { name = "AWS-AWSManagedRulesKnownBadInputsRuleSet", priority = 5, managed_rule_group_statement_name = "AWSManagedRulesKnownBadInputsRuleSet", managed_rule_group_statement_vendor_name = "AWS", metric_name = "AWS-AWSManagedRulesKnownBadInputsRuleSet" },
    { name = "AWS-AWSManagedRulesLinuxRuleSet", priority = 6, managed_rule_group_statement_name = "AWSManagedRulesLinuxRuleSet", managed_rule_group_statement_vendor_name = "AWS", metric_name = "AWS-AWSManagedRulesLinuxRuleSet" },
    { name = "AWS-AWSManagedRulesUnixRuleSet", priority = 7, managed_rule_group_statement_name = "AWSManagedRulesUnixRuleSet", managed_rule_group_statement_vendor_name = "AWS", metric_name = "AWS-AWSManagedRulesUnixRuleSet" },
    { name = "AWS-AWSManagedRulesSQLiRuleSet", priority = 8, managed_rule_group_statement_name = "AWSManagedRulesSQLiRuleSet", managed_rule_group_statement_vendor_name = "AWS", metric_name = "AWS-AWSManagedRulesSQLiRuleSet" }
  ]
}
