resource "aws_lambda_function" "ecr_scan_lambda_function" {
  count                          = local.count_ecr_scan
  function_name                  = "${var.project}-ecr-scan-${local.environment}"
  handler                        = "uk.gov.nationalarchives.ecr.scan.Lambda::process"
  role                           = aws_iam_role.ecr_scan_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/ecr-scan.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 512
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "lambda_allow_event" {
  count         = local.count_ecr_scan
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecr_scan_lambda_function[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.periodic_ecr_image_scan_event_arn
}

resource "aws_cloudwatch_log_group" "ecr_scan_lambda_log_group" {
  count             = local.count_ecr_scan
  name              = "/aws/lambda/${aws_lambda_function.ecr_scan_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "ecr_scan_lambda_policy" {
  count  = local.count_ecr_scan
  policy = templatefile("${path.module}/templates/ecr_scan_lambda.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment })
  name   = "${upper(var.project)}EcrScanLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "ecr_scan_lambda_iam_role" {
  count              = local.count_ecr_scan
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}EcrScanLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "ecr_scan_lambda_role_policy" {
  count      = local.count_ecr_scan
  policy_arn = aws_iam_policy.ecr_scan_lambda_policy.*.arn[0]
  role       = aws_iam_role.ecr_scan_lambda_iam_role.*.name[0]
}
