resource "aws_network_acl" "acl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  tags = merge(
    var.common_tags,
    map(
      "Name", var.name
    )
  )
}

resource "aws_network_acl_rule" "acl_incoming_rules" {
  for_each       = { for rule in var.ingress_rules : "rule${rule.rule_no}_${rule.egress}" => rule }
  network_acl_id = aws_network_acl.acl.id
  egress         = each.value.egress
  protocol       = "tcp"
  rule_action    = each.value.action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
  rule_number    = each.value.rule_no
}