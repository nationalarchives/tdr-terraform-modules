resource "aws_kms_key" "encryption" {
  description         = "KMS key for encryption within ${var.environment} environment"
  enable_key_rotation = true

  policy = templatefile("${path.module}/templates/${var.key_policy}.json.tpl", merge(var.policy_variables, {
    account_id                     = data.aws_caller_identity.current.account_id,
    aws_backup_service_role        = var.aws_backup_service_role_arn
    aws_backup_local_role          = var.aws_backup_local_role_arn
    transfer_service_ecs_task_role = var.transfer_service_ecs_task_role_arn
    environment                    = var.environment
  }))
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
