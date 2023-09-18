locals {
  //management account does not need the notifications transform engine aws resources
  transform_engine_count             = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
  transform_engine_v2_count          = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
  kms_export_bucket_encryption_count = var.apply_resource == true && local.environment != "mgmt" ? local.count_notifications : 0
  //encryption requires some value, as these are not relevant for management account use placeholder values
  env_var_judgment_export_bucket               = local.transform_engine_count == 0 ? "not_applicable" : var.judgment_export_s3_bucket_name
  env_var_standard_export_bucket               = local.transform_engine_count == 0 ? "not_applicable" : var.standard_export_s3_bucket_name
  env_var_transform_engine_output_sqs_endpoint = local.transform_engine_count == 0 ? "not_applicable" : data.aws_ssm_parameter.transform_engine_output_sqs_endpoint[0].value
  env_var_transform_engine_v2_sns_topic_in     = local.transform_engine_count == 0 ? "not_applicable" : data.aws_ssm_parameter.transform_engine_v2_input_sns_arn[0].value
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
      SLACK_WEBHOOK                    = aws_kms_ciphertext.environment_vars_notifications["slack_notifications_webhook"].ciphertext_blob
      SLACK_JUDGMENT_WEBHOOK           = aws_kms_ciphertext.environment_vars_notifications["slack_judgment_webhook"].ciphertext_blob
      SLACK_TDR_WEBHOOK                = aws_kms_ciphertext.environment_vars_notifications["slack_tdr_webhook"].ciphertext_blob
      SLACK_EXPORT_WEBHOOK             = aws_kms_ciphertext.environment_vars_notifications["slack_export_webhook"].ciphertext_blob
      TO_EMAIL                         = aws_kms_ciphertext.environment_vars_notifications["to_email"].ciphertext_blob
      TRANSFORM_ENGINE_OUTPUT_SQS      = aws_kms_ciphertext.environment_vars_notifications["transform_engine_output_sqs"].ciphertext_blob
      TRANSFORM_ENGINE_V2_SNS_TOPIC_IN = aws_kms_ciphertext.environment_vars_notifications["transform_engine_v2_sns_topic_in"].ciphertext_blob
      JUDGMENT_EXPORT_BUCKET           = aws_kms_ciphertext.environment_vars_notifications["judgment_export_bucket"].ciphertext_blob
      STANDARD_EXPORT_BUCKET           = aws_kms_ciphertext.environment_vars_notifications["standard_export_bucket"].ciphertext_blob
      DA_EVENT_BUS                     = aws_kms_ciphertext.environment_vars_notifications["da_event_bus"].ciphertext_blob
      DA_EVENT_BUS_KMS_KEY             = aws_kms_ciphertext.environment_vars_notifications["da_event_bus_kms_key"].ciphertext_blob
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_notifications" {
  for_each = local.count_notifications == 0 ? {} : {
    slack_tdr_webhook = data.aws_ssm_parameter.slack_webhook[0].value,
    slack_judgment_webhook = data.aws_ssm_parameter.slack_judgment_webhook[0].value,
    slack_notifications_webhook = data.aws_ssm_parameter.slack_notifications_webhook[0].value,
    slack_export_webhook = data.aws_ssm_parameter.slack_export_webhook[0].value,
    to_email = "tdr-secops@nationalarchives.gov.uk",
    transform_engine_output_sqs = local.env_var_transform_engine_output_sqs_endpoint,
    transform_engine_v2_sns_topic_in = local.env_var_transform_engine_v2_sns_topic_in,
    judgment_export_bucket = local.env_var_judgment_export_bucket,
    standard_export_bucket = local.env_var_standard_export_bucket,
    da_event_bus           = var.da_event_bus_arn,
    da_event_bus_kms_key   = var.da_event_bus_kms_key_arn
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

data "aws_ssm_parameter" "slack_notifications_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/notifications/webhook"
}

data "aws_ssm_parameter" "slack_export_webhook" {
  count = local.count_notifications
  name  = "/${local.environment}/slack/export/webhook"
}

data "aws_ssm_parameter" "transform_engine_output_sqs_arn" {
  count = local.transform_engine_count
  name  = "/${local.environment}/transform_engine/output_sqs/arn"
}

data "aws_ssm_parameter" "transform_engine_v2_input_sns_arn" {
  count = local.transform_engine_count
  name  = "/${local.environment}/transform_engine_v2/tre-in/arn"
}

data "aws_ssm_parameter" "transform_engine_v2_kms_key_arn" {
  count = local.transform_engine_count
  name  = "/${local.environment}/transform_engine_v2/kms/key_arn"
}

data "aws_ssm_parameter" "transform_engine_output_sqs_endpoint" {
  count = local.transform_engine_count
  name  = "/${local.environment}/transform_engine/output_sqs/endpoint"
}

resource "aws_cloudwatch_log_group" "notifications_lambda_log_group" {
  count = local.count_notifications
  name  = "/aws/lambda/${aws_lambda_function.notifications_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "notifications_lambda_policy" {
  count  = local.count_notifications
  policy = templatefile("${path.module}/templates/notifications_lambda.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, email = "tdr-secops@nationalarchives.gov.uk", kms_arn = var.kms_key_arn, kms_account_arn = data.aws_kms_key.encryption_key_account.arn })
  name   = "${upper(var.project)}NotificationsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_policy" "notifications_kms_bucket_key_policy" {
  count  = local.kms_export_bucket_encryption_count
  policy = templatefile("${path.module}/templates/notifications_lambda_kms_bucket_key_policy.json.tpl", { kms_export_bucket_key_arn = var.kms_export_bucket_key_arn })
  name   = "${upper(var.project)}NotificationsLambdaKMSBucketKeyPolicy${title(local.environment)}"
}

resource "aws_iam_policy" "transform_engine_notifications_lambda_policy" {
  count  = local.transform_engine_count
  policy = templatefile("${path.module}/templates/notifications_transform_engine_lambda.json.tpl", { transform_engine_output_queue_arn = data.aws_ssm_parameter.transform_engine_output_sqs_arn[0].value, transform_engine_retry_queue_arn = local.transform_engine_retry_queue, transform_engine_v2_out_queue_arn = local.transform_engine_v2_out_queue, transform_engine_v2_in_topic_arn = data.aws_ssm_parameter.transform_engine_v2_input_sns_arn[0].value, transform_engine_v2_kms_key_arn = data.aws_ssm_parameter.transform_engine_v2_kms_key_arn[0].value })
  name   = "${upper(var.project)}NotificationsTransformEngineLambdaPolicy${title(local.environment)}"
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

resource "aws_iam_role_policy_attachment" "transform_engine_notifications_policy" {
  count      = local.transform_engine_count
  policy_arn = aws_iam_policy.transform_engine_notifications_lambda_policy.*.arn[0]
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

resource "aws_lambda_event_source_mapping" "transform_engine_retry_sqs_queue_mapping" {
  count            = local.transform_engine_count
  event_source_arn = local.transform_engine_retry_queue
  function_name    = aws_lambda_function.notifications_lambda_function.*.arn[0]
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "transform_engine_v2_out_sqs_queue_mapping" {
  count            = local.transform_engine_v2_count
  event_source_arn = local.transform_engine_v2_out_queue
  function_name    = aws_lambda_function.notifications_lambda_function.*.arn[0]
  batch_size       = 1
}
