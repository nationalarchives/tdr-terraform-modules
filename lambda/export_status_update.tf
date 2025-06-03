resource "aws_lambda_function" "export_status_update_lambda_function" {
  count                          = local.count_export_status_update
  function_name                  = local.export_status_update_function_name
  handler                        = "uk.gov.nationalarchives.exportstatusupdate.Lambda::handleRequest"
  role                           = aws_iam_role.export_status_update_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/export-status-update.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      AUTH_URL           = var.auth_url
      API_URL            = var.api_url
      CLIENT_SECRET_PATH = var.backend_checks_client_secret_path
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_export_status_update_security_group.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "export_status_update_lambda_log_group" {
  count             = local.count_export_status_update
  name              = "/aws/lambda/${aws_lambda_function.export_status_update_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "export_status_update_lambda_policy" {
  count = local.count_export_status_update
  policy = templatefile("${path.module}/templates/export_status_update_policy.json.tpl", {
    account_id     = data.aws_caller_identity.current.account_id,
    environment    = local.environment, kms_arn = var.kms_key_arn,
    parameter_name = var.backend_checks_client_secret_path
  })
  name = "${upper(var.project)}ExportStatusUpdateLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "export_status_update_lambda_iam_role" {
  count              = local.count_export_status_update
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}ExportStatusUpdateLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "export_status_update_lambda_role_policy" {
  count      = local.count_export_status_update
  policy_arn = aws_iam_policy.export_status_update_lambda_policy.*.arn[0]
  role       = aws_iam_role.export_status_update_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_export_status_update_security_group" {
  count       = local.count_export_status_update
  name        = "${var.project}-lambda-export_status_update"
  description = "Export Status Update Lambda Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-export-status-update" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_export_status_update_rule" {
  count             = local.count_export_status_update
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_export_status_update_security_group[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
