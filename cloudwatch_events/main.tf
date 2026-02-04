resource "aws_cloudwatch_event_rule" "event_rule_event_pattern" {
  count         = local.count_event_pattern
  name          = var.rule_name
  description   = var.rule_description
  event_pattern = templatefile("${path.module}/templates/${var.event_pattern}_pattern.json.tpl", var.event_variables)
}

resource "aws_cloudwatch_event_rule" "event_rule_event_schedule" {
  count               = local.count_event_schedule
  name                = var.rule_name
  description         = var.rule_description
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "event_target" {
  for_each = var.event_target_arns
  rule     = local.event_rule_name
  arn      = each.value
}
