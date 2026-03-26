output "all_domains_domains_list" {
  value = aws_route53_resolver_firewall_domain_list.all_domains
}

output "walled_garden_rule_group" {
  value = aws_route53_resolver_firewall_rule_group.walled_garden
}
