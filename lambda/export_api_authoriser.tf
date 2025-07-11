resource "aws_lambda_function" "export_api_authoriser_lambda_function" {
  count                          = local.count_export_api_authoriser
  function_name                  = local.export_api_authoriser_function_name
  handler                        = "uk.gov.nationalarchives.consignmentexport.authoriser.Lambda::process"
  role                           = aws_iam_role.export_api_authoriser_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/export-authoriser.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 4096
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      API_URL = aws_kms_ciphertext.environment_vars_export_api_authoriser["api_url"].ciphertext_blob
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_export_api_authoriser.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_export_api_authoriser" {
  for_each  = local.count_export_api_authoriser == 0 ? {} : { api_url = "${var.api_url}/graphql" }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.export_api_authoriser_function_name }
}

resource "aws_cloudwatch_log_group" "export_api_authoriser_lambda_log_group" {
  count             = local.count_export_api_authoriser
  name              = "/aws/lambda/${aws_lambda_function.export_api_authoriser_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_role" "export_api_authoriser_lambda_iam_role" {
  count              = local.count_export_api_authoriser
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}ExportApiAuthoriserLambdaRole${title(local.environment)}"
}

resource "aws_iam_policy" "export_authoriser_policy" {
  count  = local.count_export_api_authoriser
  name   = "${upper(var.project)}ExportApiAuthoriserLambdaPolicy${title(local.environment)}"
  policy = templatefile("${path.module}/templates/export_authoriser_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, kms_arn = var.kms_key_arn })
}

resource "aws_iam_role_policy_attachment" "export_authoriser_attachment" {
  count      = local.count_export_api_authoriser
  policy_arn = aws_iam_policy.export_authoriser_policy[count.index].arn
  role       = aws_iam_role.export_api_authoriser_lambda_iam_role[count.index].id
}

resource "aws_lambda_permission" "export_api_lambda_permissions" {
  count         = local.count_export_api_authoriser
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.project}-export-api-authoriser-${local.environment}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_arn}/authorizers/*"
}

resource "aws_lambda_permission" "backend_checks_api_lambda_permissions" {
  count         = local.count_export_api_authoriser
  statement_id  = "AllowExecutionFromBackendChecksApi"
  action        = "lambda:InvokeFunction"
  function_name = "${var.project}-export-api-authoriser-${local.environment}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.backend_checks_api_arn}/authorizers/*"
}

resource "aws_lambda_permission" "draft_metadata_api_lambda_permissions" {
  count         = local.count_export_api_authoriser
  statement_id  = "AllowExecutionFromDraftMetadataApi"
  action        = "lambda:InvokeFunction"
  function_name = "${var.project}-export-api-authoriser-${local.environment}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.draft_metadata_api_arn}/authorizers/*"
}

resource "aws_security_group" "lambda_export_api_authoriser" {
  count       = local.count_export_api_authoriser
  name        = "allow-https-outbound-export-api-authoriser"
  description = "Allow HTTPS outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-allow-https-outbound-export-api-authoriser" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_export_api_authoriser_rule" {
  count             = local.count_export_api_authoriser
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_export_api_authoriser[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
