resource "aws_shield_protection" "shield_protection" {
  for_each     = var.resource_arns
  name         = "${upper(var.project)}ShieldProtection"
  resource_arn = each.value
}
