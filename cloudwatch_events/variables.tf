variable "event_pattern" {
  default     = ""
  description = "The event pattern for the rule. Cannot be used with schedule"
}

variable "event_target_arns" {
  description = "Name to arn map for the event target resources"
  type = map(string)
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
