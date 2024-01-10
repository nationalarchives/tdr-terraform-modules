resource "aws_lambda_function" "reporting_lambda_function" {
  count                          = local.count_reporting
  function_name                  = local.reporting_function_name
  handler                        = "app.report.handler"
  role                           = aws_iam_role.reporting_lambda_iam_role.*.arn[0]
  runtime                        = "python3.9"
  filename                       = "${path.module}/functions/reporting.zip"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      AUTH_URL                 = var.auth_url
      CONSIGNMENT_API_URL      = var.api_url
      CLIENT_ID                = var.keycloak_reporting_client_id
      CLIENT_SECRET            = aws_kms_ciphertext.environment_vars_reporting["client_secret"].ciphertext_blob
      CLIENT_SECRET_PATH       = var.reporting_client_secret_path
      SLACK_BOT_TOKEN          = aws_kms_ciphertext.environment_vars_reporting["slack_bot_token"].ciphertext_blob
      TDR_REPORTING_SLACK_CHANNEL_ID = aws_kms_ciphertext.environment_vars_reporting["tdr_reporting_slack_channel_id"].ciphertext_blob
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_reporting_security_group.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }

  depends_on = [var.mount_target_zero, var.mount_target_one]
}

resource "aws_kms_ciphertext" "environment_vars_reporting" {
  for_each = local.count_reporting == 0 ? {} : {
    slack_bot_token          = var.slack_bot_token,
    client_secret            = var.keycloak_reporting_client_secret
    tdr_reporting_slack_channel_id = var.tdr_reporting_slack_channel_id
  }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.reporting_function_name }
}

resource "aws_cloudwatch_log_group" "reporting_lambda_log_group" {
  count = local.count_reporting
  name  = "/aws/lambda/${aws_lambda_function.reporting_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "reporting_lambda_policy" {
  count = local.count_reporting
  policy = templatefile("${path.module}/templates/reporting_policy.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id, environment = local.environment, kms_arn = var.kms_key_arn, parameter_name = var.reporting_client_secret_path
  })
  name = "${upper(var.project)}ReportingLambdaPolicy"
}

resource "aws_iam_role" "reporting_lambda_iam_role" {
  count              = local.count_reporting
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ReportingLambdaRole"
}

resource "aws_iam_role_policy_attachment" "reporting_lambda_role_policy" {
  count      = local.count_reporting
  policy_arn = aws_iam_policy.reporting_lambda_policy.*.arn[0]
  role       = aws_iam_role.reporting_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_reporting_security_group" {
  count       = local.count_reporting
  name        = "${var.project}-lambda-reporting"
  description = "Reporting Lambda Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-reporting" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_reporting_rule" {
  count             = local.count_reporting
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_reporting_security_group[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
