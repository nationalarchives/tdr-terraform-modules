data "template_file" "key_policy" {
  template = templatefile("${path.module}/templates/${var.key_policy}.json.tpl", merge(var.policy_variables, { account_id = data.aws_caller_identity.current.account_id, environment = var.environment }))
}

resource "aws_kms_key" "encryption" {
  description              = "KMS key for encryption within ${var.environment} environment"
  enable_key_rotation      = var.enable_key_rotation
  policy                   = data.template_file.key_policy.rendered
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-${var.function}-${var.environment}" }
    )
  )
}

resource "aws_kms_alias" "encryption" {
  name          = "alias/${var.project}-${var.function}-${var.environment}"
  target_key_id = aws_kms_key.encryption.key_id
}
