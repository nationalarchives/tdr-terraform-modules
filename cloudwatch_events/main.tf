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

resource "aws_cloudwatch_event_target" "sqs_event_target" {
  count = local.count_sqs_event_target
  rule  = local.event_rule_name
  arn   = var.log_group_event_target_arn
}

resource "aws_cloudwatch_event_target" "lambda_event_target" {
  for_each = var.lambda_event_target_arn
  rule     = local.event_rule_name
  arn      = each.value
}

resource "aws_cloudwatch_event_target" "sns_topic_event_target" {
  for_each = var.sns_topic_event_target_arn
  rule     = local.event_rule_name
  arn      = each.value
}
