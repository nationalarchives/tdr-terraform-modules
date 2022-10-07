variable "sns_topics" {
  type = set(object({
    arn = string
  }))
  default   = []
  sensitive = true
}

variable "event_pattern" {
  default     = ""
  description = "The event pattern for the rule. Cannot be used with schedule"
}
variable "log_group_event_target_arn" {
  description = "A Cloudwatch log group ARN to attach to the event"
  default     = ""
}
variable "lambda_event_target_arn" {
  description = "A Lambda ARN to attach to the event"
  type        = set(string)
  default     = []
}
variable "sns_topic_event_target_arn" {
  description = "A SNS topic ARNs to attach to the event"
  type        = set(string)
  default     = []
}
variable "rule_name" {}
variable "rule_description" {
  default = ""
}
variable "event_variables" {
  type        = map(string)
  default     = {}
  description = "A map of variables to pass to specific event patterns"
}

variable "schedule" {
  description = "The schedule for the event rule. Cannot be used with event pattern"
  default     = ""
}
