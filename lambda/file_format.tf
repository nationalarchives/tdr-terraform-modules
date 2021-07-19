resource "aws_lambda_function" "file_format_lambda_function" {
  count                          = local.count_file_format
  function_name                  = local.file_format_function_name
  handler                        = "uk.gov.nationalarchives.fileformat.Lambda::process"
  role                           = aws_iam_role.file_format_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/file-format.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      ENVIRONMENT    = aws_kms_ciphertext.environment_vars_file_format["environment"].ciphertext_blob
      INPUT_QUEUE    = aws_kms_ciphertext.environment_vars_file_format["input_queue"].ciphertext_blob
      OUTPUT_QUEUE   = aws_kms_ciphertext.environment_vars_file_format["output_queue"].ciphertext_blob
      ROOT_DIRECTORY = aws_kms_ciphertext.environment_vars_file_format["root_directory"].ciphertext_blob
    }
  }
  file_system_config {
    # EFS file system access point ARN
    arn              = var.backend_checks_efs_access_point.arn
    local_mount_path = var.backend_checks_efs_root_directory_path
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.allow_efs_lambda_file_format.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }

  depends_on = [var.mount_target_zero, var.mount_target_one]
}

resource "aws_kms_ciphertext" "environment_vars_file_format" {
  for_each  = local.count_file_format == 0 ? {} : { environment = local.environment, input_queue = local.file_format_queue_url, output_queue = local.api_update_queue_url, root_directory = var.backend_checks_efs_root_directory_path }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.file_format_function_name }
}

resource "aws_lambda_event_source_mapping" "file_format_sqs_queue_mapping" {
  count            = local.count_file_format
  event_source_arn = local.file_format_queue
  function_name    = aws_lambda_function.file_format_lambda_function.*.arn[0]
  batch_size       = 1
}

resource "aws_cloudwatch_log_group" "file_format_lambda_log_group" {
  count = local.count_file_format
  name  = "/aws/lambda/${aws_lambda_function.file_format_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "file_format_lambda_policy" {
  count  = local.count_file_format
  policy = templatefile("${path.module}/templates/file_format_lambda.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, update_queue = local.api_update_queue, input_sqs_queue = local.file_format_queue, file_system_id = var.file_system_id, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}FileFormatLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "file_format_lambda_iam_role" {
  count              = local.count_file_format
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}FileFormatRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "file_format_lambda_role_policy" {
  count      = local.count_file_format
  policy_arn = aws_iam_policy.file_format_lambda_policy.*.arn[0]
  role       = aws_iam_role.file_format_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "allow_efs_lambda_file_format" {
  count       = local.count_file_format
  name        = "allow-efs"
  description = "Allow EFS inbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-allow-efs-download-files" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_file_format" {
  count             = local.count_file_format
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_efs_lambda_file_format[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "file_format_outbound_efs_rule" {
  count                    = local.count_file_format
  from_port                = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_efs_lambda_file_format[count.index].id
  to_port                  = 2049
  type                     = "egress"
  source_security_group_id = var.efs_security_group_id
}
