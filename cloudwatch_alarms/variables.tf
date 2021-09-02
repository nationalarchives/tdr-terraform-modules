variable "environment" {}
variable "function" {}
variable "project" {}

variable "evaluation_period" {
  default     = 1
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "period" {
  default     = 60
  description = "The period in seconds over which the specified statistic is applied."
}
variable "datapoints_to_alarm" {
  default     = 1
  description = "How many datapoints over the threshold to trigger the alarm"
}
variable "threshold" {
  description = "The threshold for the metric above which an alarm is triggered"
}

variable "dimensions" {
  description = "Additional data which is passed from the Cloudwatch agent"
  type        = map(string)
  default     = {}
}

variable "metric_name" {
  description = "The name of the metric to be monitored"
}

variable "namespace" {
  default     = "CWAgent"
  description = "The namespace configured in Cloudwatch agent. Defaults to CWAgent"
}

variable "notification_topic" {
  default     = ""
  description = "The SNS topic to send alarm notifications to"
}

variable "statistic" {
  default     = "Average"
  description = "Can be SampleCount, Average, Sum, Minimum, Maximum"
}

variable "comparison_operator" {
  default     = "GreaterThanThreshold"
  description = "Can be GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold"
}
variable "treat_missing_data" {
  default     = "breaching"
  description = "Sets how this alarm is to handle missing data points. Can be missing, ignore, breaching and notBreaching. Default is 'breaching' so there will be an alert if the Cloudwatch agent fails"
}
