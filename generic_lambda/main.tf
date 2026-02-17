data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  handler       = var.handler
  role          = aws_iam_role.lambda_iam_role.arn
  runtime       = var.runtime
  filename      = startswith(var.runtime, "java") ? "${path.module}/functions/generic.jar" : "${path.module}/functions/generic.zip"
  timeout       = var.timeout_seconds
  memory_size   = var.memory_size

  ephemeral_storage {
    size = var.storage_size
  }

  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.tags
  environment {
    variables = local.all_env_vars
  }

  dynamic "file_system_config" {
    for_each = var.efs_access_points
    content {
      arn              = file_system_config.value.access_point_arn
      local_mount_path = file_system_config.value.mount_path
    }
  }
  dynamic "vpc_config" {
    for_each = var.vpc_config
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.tags
}

locals {
  encrypted_env_vars = { for k, v in var.encrypted_env_vars : k => aws_kms_ciphertext.encrypted_environment_variables[k].ciphertext_blob }
  all_env_vars       = merge(local.encrypted_env_vars, var.plaintext_env_vars)
}

resource "aws_kms_ciphertext" "encrypted_environment_variables" {
  for_each  = var.encrypted_env_vars
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = var.function_name }
}

resource "aws_lambda_event_source_mapping" "sqs_queue_mappings" {
  for_each         = var.lambda_sqs_queue_mappings
  event_source_arn = each.key
  function_name    = aws_lambda_function.lambda_function.*.arn[0]
  batch_size       = 1
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = var.lambda_invoke_permissions
  statement_id  = "AllowExecutionFrom${title(split(".", each.key)[0])}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = each.key
  source_arn    = each.value
}

resource "aws_iam_role" "lambda_iam_role" {
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.id })
  name               = var.role_name
}

resource "aws_iam_policy" "lambda_policies" {
  for_each = var.policies
  policy   = each.value
  name     = each.key
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  for_each   = aws_iam_policy.lambda_policies
  policy_arn = each.value.arn
  role       = aws_iam_role.lambda_iam_role.name
}

resource "aws_iam_role_policy_attachment" "existing_policy_attachment" {
  for_each   = var.policy_attachments
  policy_arn = each.value
  role       = aws_iam_role.lambda_iam_role.name
}
