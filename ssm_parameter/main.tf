variable "parameters" {
  type = set(object({
    name        = string
    type        = string
    value       = string
    description = string
  }))
  default = []
}

variable "random_parameters" {
  type = set(object({
    name        = string
    type        = string
    value       = string
    description = string
  }))
  default = []
}

variable "common_tags" {}

resource "aws_ssm_parameter" "ssm_parameter" {
  for_each    = { for ssm_parameter in var.parameters : ssm_parameter.name => ssm_parameter }
  name        = each.value.name
  type        = each.value.type
  value       = each.value.value
  description = each.value.description
  overwrite   = true
  tags        = var.common_tags
}

resource "aws_ssm_parameter" "ssm_parameter_ignore_value" {
  for_each    = { for ssm_parameter in var.random_parameters : ssm_parameter.name => ssm_parameter }
  name        = each.value.name
  type        = each.value.type
  value       = each.value.value
  description = each.value.description
  overwrite   = true
  tags        = var.common_tags
  lifecycle {
    ignore_changes = [value]
  }
}

output "params" {
  value = merge(aws_ssm_parameter.ssm_parameter, aws_ssm_parameter.ssm_parameter_ignore_value)
}
