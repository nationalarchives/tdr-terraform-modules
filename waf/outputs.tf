output "ip_set_arn" {
  value = var.trusted_ips == "" ? "" : aws_wafv2_ip_set.trusted[0].arn
}

output "rule_group_arn" {
  value = aws_wafv2_rule_group.rule_group.arn
}

output "blocked_ip_set_arn" {
  value = var.blocked_ips == "" ? "" : aws_wafv2_ip_set.blocked_ips[0].arn
}

output "blocked_rule_group_arn" {
  value = length(aws_wafv2_rule_group.block_ips_rule_group) > 0 ? aws_wafv2_rule_group.block_ips_rule_group[0].arn : ""
}

