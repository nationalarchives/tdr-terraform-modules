locals {
  //management account does not need the notifications digital archiving event bus aws resources
  da_event_bus_count                 = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
  kms_export_bucket_encryption_count = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
}

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
      SLACK_WEBHOOK                 = aws_kms_ciphertext.environment_vars_notifications["slack_notifications_webhook"].ciphertext_blob
      SLACK_JUDGMENT_WEBHOOK        = aws_kms_ciphertext.environment_vars_notifications["slack_judgment_webhook"].ciphertext_blob
      SLACK_STANDARD_WEBHOOK        = aws_kms_ciphertext.environment_vars_notifications["slack_standard_webhook"].ciphertext_blob
      SLACK_TDR_WEBHOOK             = aws_kms_ciphertext.environment_vars_notifications["slack_tdr_webhook"].ciphertext_blob
      SLACK_EXPORT_WEBHOOK          = aws_kms_ciphertext.environment_vars_notifications["slack_export_webhook"].ciphertext_blob
      TO_EMAIL                      = aws_kms_ciphertext.environment_vars_notifications["to_email"].ciphertext_blob
      DA_EVENT_BUS                  = aws_kms_ciphertext.environment_vars_notifications["da_event_bus"].ciphertext_blob
      TRANSFER_COMPLETE_TEMPLATE_ID = aws_kms_ciphertext.environment_vars_notifications["transfer_complete_template_id"].ciphertext_blob
      GOV_UK_NOTIFY_API_KEY         = aws_kms_ciphertext.environment_vars_notifications["gov_uk_notify_api_key"].ciphertext_blob
      SEND_GOV_UK_NOTIFICATIONS     = aws_kms_ciphertext.environment_vars_notifications["send_gov_uk_notifications"].ciphertext_blob
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }

  vpc_config {
    security_group_ids = var.notifications_vpc_config.security_group_ids
    subnet_ids         = var.notifications_vpc_config.subnet_ids
  }
}

resource "aws_kms_ciphertext" "environment_vars_notifications" {
  for_each = local.count_notifications == 0 ? {} : {
    slack_tdr_webhook             = data.aws_ssm_parameter.slack_webhook[0].value,
    slack_judgment_webhook        = data.aws_ssm_parameter.slack_judgment_webhook[0].value,
    slack_standard_webhook        = data.aws_ssm_parameter.slack_standard_webhook[0].value,
    slack_notifications_webhook   = data.aws_ssm_parameter.slack_notifications_webhook[0].value,
    slack_export_webhook          = data.aws_ssm_parameter.slack_export_webhook[0].value,
    to_email                      = "tdr-secops@nationalarchives.gov.uk",
    da_event_bus                  = var.da_event_bus_arn
    transfer_complete_template_id = data.aws_ssm_parameter.gov_uk_transfer_complete_template_id[0].value
    gov_uk_notify_api_key         = data.aws_ssm_parameter.gov_uk_notify_api_key[0].value
    send_gov_uk_notifications     = local.environment == "prod"
  }
  # This lambda is created by the tdr-terraform-backend project as it only exists in the management account so we can't use any KMS keys
  # created by the terraform environments project as they won't exist when we first run the backend project.
  # This KMS key is created by tdr-accounts which means it will exist when we run the terraform backend project for the first time
  key_id    = "alias/tdr-account-${local.environment}"
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.notifications_function_name }
}

data "aws_kms_key" "encryption_key_account" {
  key_id = "alias/tdr-account-${local.environment}"
}

data "aws_ssm_parameter" "slack_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/notification/webhook"
}

data "aws_ssm_parameter" "slack_judgment_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/judgment/webhook"
}

data "aws_ssm_parameter" "slack_standard_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/standard/webhook"
}

data "aws_ssm_parameter" "slack_notifications_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/notifications/webhook"
}

data "aws_ssm_parameter" "slack_export_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/export/webhook"
}

data "aws_ssm_parameter" "gov_uk_transfer_complete_template_id" {
  count = local.count_notifications
  name  = "/${local.environment}/gov_uk_notify/transfer_complete_template_id"
}

data "aws_ssm_parameter" "gov_uk_notify_api_key" {
  count = local.count_notifications
  name  = "/${local.environment}/keycloak/govuk_notify/api_key"
}

resource "aws_cloudwatch_log_group" "notifications_lambda_log_group" {
  count             = local.count_notifications
  name              = "/aws/lambda/${aws_lambda_function.notifications_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "notifications_lambda_policy" {
  count = local.count_notifications
  policy = templatefile("${path.module}/templates/notifications_lambda.json.tpl", {
    account_id  = data.aws_caller_identity.current.account_id,
    environment = local.environment,
    email       = "tdr-secops@nationalarchives.gov.uk",
    kms_arn     = var.kms_key_arn,
  kms_account_arn = data.aws_kms_key.encryption_key_account.arn })
  name = "${upper(var.project)}NotificationsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_policy" "notifications_kms_bucket_key_policy" {
  count  = local.kms_export_bucket_encryption_count
  policy = templatefile("${path.module}/templates/notifications_lambda_kms_bucket_key_policy.json.tpl", { kms_export_bucket_key_arn = var.kms_export_bucket_key_arn })
  name   = "${upper(var.project)}NotificationsLambdaKMSBucketKeyPolicy${title(local.environment)}"
}

resource "aws_iam_policy" "da_event_bus_notifications_lambda_policy" {
  count = local.da_event_bus_count
  policy = templatefile("${path.module}/templates/notifications_lambda_da_event_bus_policy.json.tpl", {
    da_event_bus_arn         = var.da_event_bus_arn,
    da_event_bus_kms_key_arn = var.da_event_bus_kms_key_arn
  })
  name = "${upper(var.project)}NotificationsTransformEngineLambdaPolicy${title(local.environment)}"
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

resource "aws_iam_role_policy_attachment" "notifications_kms_bucket_key_policy" {
  count      = local.kms_export_bucket_encryption_count
  policy_arn = aws_iam_policy.notifications_kms_bucket_key_policy.*.arn[0]
  role       = aws_iam_role.notifications_lambda_iam_role.*.name[0]
}

resource "aws_iam_role_policy_attachment" "da_event_bus_notifications_policy" {
  count      = local.da_event_bus_count
  policy_arn = aws_iam_policy.da_event_bus_notifications_lambda_policy.*.arn[0]
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

resource "aws_lambda_permission" "lambda_permissions_principals" {
  for_each      = local.principal_arns
  statement_id  = "AllowExecutionFrom${split(":", upper(each.key))[2]}${split(":", each.key)[5]}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifications_lambda_function.*.arn[0]
  principal     = "${split(":", (each.key))[2]}.amazonaws.com"
  source_arn    = each.value
}

resource "aws_sns_topic_subscription" "intg_topic_subscription" {
  for_each  = var.sns_topic_arns
  endpoint  = aws_lambda_function.notifications_lambda_function.*.arn[0]
  protocol  = "lambda"
  topic_arn = each.value
}

resource "aws_iam_policy" "vpc_access_policy" {
  count       = local.count_notifications
  policy      = templatefile("${path.module}/templates/lambda_vpc_policy.json.tpl", {})
  name        = "${local.notifications_function_name}-vpc-policy"
  description = "Allows access to the VPC for function ${local.notifications_function_name}"
}

resource "aws_iam_role_policy_attachment" "vpc_access_policy_attachment" {
  count      = local.count_notifications
  policy_arn = aws_iam_policy.vpc_access_policy[0].arn
  role       = aws_iam_role.notifications_lambda_iam_role[0].name
}
