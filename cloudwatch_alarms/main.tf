resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_alarm" {
  alarm_name          = "${var.project}-${var.function}-${var.environment}"
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_period
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = var.treat_missing_data
  threshold           = var.threshold
  dimensions          = var.dimensions
  metric_name         = var.metric_name
  namespace           = var.namespace
  actions_enabled     = var.notification_topic == "" ? false : true
  alarm_actions       = var.notification_topic == "" ? [] : [var.notification_topic]
  ok_actions          = var.notification_topic == "" ? [] : [var.notification_topic]
  statistic           = var.statistic
  period              = var.period
}