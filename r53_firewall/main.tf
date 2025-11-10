# A self contained module to create a whitelist based (walled garden) r53 firewall 
resource "aws_route53_resolver_firewall_domain_list" "whitelist" {
  name    = format("whitelist-%s", var.environment_name)
  domains = var.whitelist_domains
  tags    = var.common_tags
}

resource "aws_route53_resolver_firewall_domain_list" "all_domains" {
  name    = format("all_domains-%s", var.environment_name)
  domains = ["*."]
  tags    = var.common_tags
}

resource "aws_route53_resolver_firewall_rule_group" "walled_garden" {
  name = "whitelist"
  tags = var.common_tags
}

resource "aws_route53_resolver_firewall_rule" "whitelist" {
  name                    = "whitelist-allow"
  action                  = "ALLOW"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.whitelist.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.walled_garden.id
  priority                = 100
}

# NB: Block response can't be set if action is not BLOCK
resource "aws_route53_resolver_firewall_rule" "block_all" {
  name                    = "block-all"
  block_response          = var.alert_only ? null : "NODATA"
  action                  = var.alert_only ? "ALERT" : "BLOCK"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.all_domains.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.walled_garden.id
  priority                = 200
}

resource "aws_route53_resolver_firewall_rule_group_association" "walled_garden" {
  name                   = "whitelist"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.walled_garden.id
  priority               = 101
  vpc_id                 = var.vpc_id
}
