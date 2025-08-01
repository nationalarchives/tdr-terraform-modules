resource "aws_iam_policy" "log_data_lambda_base_policy" {
  count  = local.count_log_data
  name   = "${upper(var.project)}LogDataLambdaBase${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/lambda/templates/lambda_base.json.tpl", {})
}

resource "aws_iam_role" "log_data_assume_role" {
  count              = local.count_log_data
  name               = "${upper(var.project)}LogDataAssumeRole${title(local.environment)}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "log_data_base_policy_attach" {
  count      = local.count_log_data
  role       = aws_iam_role.log_data_assume_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_lambda_base_policy.*.arn[0]
}

resource "aws_iam_policy" "log_data_policy" {
  count  = local.count_log_data
  name   = "${upper(var.project)}LogData${title(local.environment)}"
  policy = templatefile("./tdr-terraform-modules/lambda/templates/log_data.json.tpl", { mgmt_account_id = data.aws_ssm_parameter.mgmt_account_number.*.value[0], kms_arn = var.kms_key_arn })
}

resource "aws_iam_role_policy_attachment" "log_data_policy_attach" {
  count      = local.count_log_data
  role       = aws_iam_role.log_data_assume_role.*.name[0]
  policy_arn = aws_iam_policy.log_data_policy.*.arn[0]
}

data "archive_file" "log_data_lambda" {
  type        = "zip"
  source_file = "./tdr-terraform-modules/lambda/functions/log-data/lambda_function.py"
  output_path = "/tmp/log-data-lambda.zip"
}

resource "aws_lambda_function" "log_data_lambda" {
  count                          = local.count_log_data
  filename                       = data.archive_file.log_data_lambda.output_path
  function_name                  = local.log_data_function_name
  description                    = "Aggregate log data to a target S3 bucket"
  role                           = aws_iam_role.log_data_assume_role.*.arn[0]
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = data.archive_file.log_data_lambda.output_base64sha256
  runtime                        = "python3.7"
  timeout                        = var.timeout_seconds
  publish                        = true
  reserved_concurrent_executions = var.reserved_concurrency

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-log-data-${local.environment}" }
    )
  )

  environment {
    variables = {
      TARGET_S3_BUCKET = aws_kms_ciphertext.environment_vars_log_data["target_s3_bucket"].ciphertext_blob
    }
  }
}

resource "aws_kms_ciphertext" "environment_vars_log_data" {
  for_each  = local.count_log_data == 0 ? {} : { target_s3_bucket = var.target_s3_bucket }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.log_data_function_name }
}

resource "aws_sns_topic_subscription" "log_data" {
  count     = local.count_log_data
  topic_arn = var.log_data_sns_topic
  protocol  = "lambda"
  endpoint  = aws_lambda_function.log_data_lambda.*.arn[0]
}

resource "aws_lambda_permission" "log_data" {
  count         = local.count_log_data
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_data_lambda.*.arn[0]
  principal     = "sns.amazonaws.com"
  source_arn    = var.log_data_sns_topic
}
