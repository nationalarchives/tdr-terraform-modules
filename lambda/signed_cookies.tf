resource "aws_lambda_function" "signed_cookies_lambda_function" {
  count                          = local.count_signed_cookies
  function_name                  = local.signed_cookies_function_name
  handler                        = "signed_cookies.handler"
  role                           = aws_iam_role.signed_cookies_lambda_iam_role.*.arn[0]
  runtime                        = "python3.9"
  filename                       = "${path.module}/functions/signed-cookies.zip"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      PRIVATE_KEY           = aws_kms_ciphertext.environment_vars_signed_cookies["private_key"].ciphertext_blob
      FRONTEND_URL          = var.frontend_url
      AUTH_URL              = var.auth_url
      UPLOAD_DOMAIN         = var.upload_domain
      ENVIRONMENT           = var.environment_full
      KEY_PAIR_ID           = aws_kms_ciphertext.environment_vars_signed_cookies["key_pair_id"].ciphertext_blob,
      COOKIE_EXPIRY_MINUTES = var.user_session_timeout_mins
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_signed_cookies_security_group.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }

  depends_on = [var.mount_target_zero, var.mount_target_one]
}

resource "aws_kms_ciphertext" "environment_vars_signed_cookies" {
  for_each = local.count_signed_cookies == 0 ? {} : {
    private_key = data.aws_ssm_parameter.cloudfront_private_key_pem[0].value,
    key_pair_id = var.cloudfront_key_pair_id
  }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.signed_cookies_function_name }
}

resource "aws_cloudwatch_log_group" "signed_cookies_lambda_log_group" {
  count             = local.count_signed_cookies
  name              = "/aws/lambda/${aws_lambda_function.signed_cookies_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "signed_cookies_lambda_policy" {
  count  = local.count_signed_cookies
  policy = templatefile("${path.module}/templates/signed_cookies_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}SignedCookiesLambdaPolicy"
}

resource "aws_iam_role" "signed_cookies_lambda_iam_role" {
  count              = local.count_signed_cookies
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}SignedCookiesLambdaRole"
}

resource "aws_iam_role_policy_attachment" "signed_cookies_lambda_role_policy" {
  count      = local.count_signed_cookies
  policy_arn = aws_iam_policy.signed_cookies_lambda_policy.*.arn[0]
  role       = aws_iam_role.signed_cookies_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_signed_cookies_security_group" {
  count       = local.count_signed_cookies
  name        = "${var.project}-lambda-signed_cookies"
  description = "Signed Cookies Lambda Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-signed-cookies" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_signed_cookies_rule" {
  count             = local.count_signed_cookies
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_signed_cookies_security_group[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lambda_permission" "signed_cookies_lambda_permissions" {
  count         = local.count_signed_cookies
  statement_id  = "AllowExecutionFromPythonSignedCookiesApi"
  action        = "lambda:InvokeFunction"
  function_name = local.signed_cookies_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_arn}/*/GET/cookies"
}
