resource "aws_lambda_function" "export_failure_status_lambda_function" {
  count                          = local.count_export_failure_status
  function_name                  = local.export_failure_status_function_name
  handler                        = "export_failure_status.handler"
  role                           = aws_iam_role.export_failure_status_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/export-failure-status.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      PRIVATE_KEY   = aws_kms_ciphertext.environment_vars_export_failure_status["private_key"].ciphertext_blob
      FRONTEND_URL  = var.frontend_url
      AUTH_URL      = var.auth_url
      UPLOAD_DOMAIN = var.upload_domain
      ENVIRONMENT   = var.environment_full
      KEY_PAIR_ID   = aws_kms_ciphertext.environment_vars_export_failure_status["key_pair_id"].ciphertext_blob,
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_export_failure_status_security_group.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_export_failure_status" {
  for_each = local.count_export_failure_status == 0 ? {} : {
    private_key = data.aws_ssm_parameter.cloudfront_private_key_pem[0].value,
    key_pair_id = var.cloudfront_key_pair_id
  }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.export_failure_status_function_name }
}

resource "aws_cloudwatch_log_group" "export_failure_status_lambda_log_group" {
  count = local.count_export_failure_status
  name  = "/aws/lambda/${aws_lambda_function.export_failure_status_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "export_failure_status_lambda_policy" {
  count  = local.count_export_failure_status
  policy = templatefile("${path.module}/templates/export_failure_status_policy.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id,
    environment = local.environment, kms_arn = var.kms_key_arn
  })
  name   = "${upper(var.project)}ExportFailureStatusLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "export_failure_status_lambda_iam_role" {
  count              = local.count_export_failure_status
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ExportFailureStatusLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "export_failure_status_lambda_role_policy" {
  count      = local.count_export_failure_status
  policy_arn = aws_iam_policy.export_failure_status_lambda_policy.*.arn[0]
  role       = aws_iam_role.export_failure_status_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_export_failure_status_security_group" {
  count       = local.count_export_failure_status
  name        = "${var.project}-lambda-export_failure_status"
  description = "Export Failure Status Lambda Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-export-failure-status" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_export_failure_status_rule" {
  count             = local.count_export_failure_status
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_export_failure_status_security_group[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
