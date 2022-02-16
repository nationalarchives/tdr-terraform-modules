resource "aws_lambda_function" "notifications_lambda_function" {
  count                          = local.count_notifications
  function_name                  = local.notifications_function_name
  handler                        = "uk.gov.nationalarchives.notifications.Lambda::process"
  role                           = aws_iam_role.notifications_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/notifications.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      SLACK_WEBHOOK         = aws_kms_ciphertext.environment_vars_notifications["slack_webhook"].ciphertext_blob
      TO_EMAIL              = aws_kms_ciphertext.environment_vars_notifications["to_email"].ciphertext_blob
      MUTED_VULNERABILITIES = aws_kms_ciphertext.environment_vars_notifications["muted_vulnerabilities"].ciphertext_blob
      TRANSFORM_ENGINE_SQS  = aws_kms_ciphertext.environment_vars_notifications["transform_engine_sqs"].ciphertext_blob
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_notifications" {
  for_each = local.count_notifications == 0 ? {} : { slack_webhook = data.aws_ssm_parameter.slack_webhook[0].value, to_email = "tdr-secops@nationalarchives.gov.uk", muted_vulnerabilities = join(",", var.muted_scan_alerts), transform_engine_sqs = data.aws_ssm_parameter.transform_engine_sqs[0].value }
  # This lambda is created by the tdr-terraform-backend project as it only exists in the management account so we can't use any KMS keys
  # created by the terraform environments project as they won't exist when we first run the backend project.
  # This KMS key is created by tdr-accounts which means it will exist when we run the terraform backend project for the first time
  key_id    = "alias/tdr-account-${local.environment}"
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.notifications_function_name }
}

data "aws_kms_key" "encryption_key" {
  key_id = "alias/tdr-account-${local.environment}"
}

data "aws_ssm_parameter" "slack_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/notification/webhook"
}

data "aws_ssm_parameter" "transform_engine_sqs" {
  count = local.count_notifications
  name  = "/${local.environment}/transform_engine/sqs"
}

resource "aws_cloudwatch_log_group" "notifications_lambda_log_group" {
  count = local.count_notifications
  name  = "/aws/lambda/${aws_lambda_function.notifications_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "notifications_lambda_policy" {
  count  = local.count_notifications
  policy = templatefile("${path.module}/templates/notifications_lambda.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, email = "tdr-secops@nationalarchives.gov.uk", kms_arn = data.aws_kms_key.encryption_key.arn })
  name   = "${upper(var.project)}NotificationsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "notifications_lambda_iam_role" {
  count              = local.count_notifications
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}NotificationsLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "notifications_lambda_role_policy" {
  count      = local.count_notifications
  policy_arn = aws_iam_policy.notifications_lambda_policy.*.arn[0]
  role       = aws_iam_role.notifications_lambda_iam_role.*.name[0]
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = nonsensitive(var.event_rule_arns)
  statement_id  = "AllowExecutionFromEvents${split("/", each.key)[1]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "events.amazonaws.com"
  source_arn    = each.value
}

resource "aws_lambda_permission" "lambda_permissions_sns" {
  for_each      = var.sns_topic_arns
  statement_id  = "AllowExecutionFromSNS${split(":", each.key)[5]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "sns.amazonaws.com"
  source_arn    = each.value
}

resource "aws_sns_topic_subscription" "intg_topic_subscription" {
  for_each  = var.sns_topic_arns
  endpoint  = aws_lambda_function.notifications_lambda_function.*.arn[0]
  protocol  = "lambda"
  topic_arn = each.value
}
