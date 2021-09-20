resource "aws_lambda_function" "sign_cookies_lambda_function" {
  count                          = local.count_sign_cookies
  function_name                  = local.sign_cookies_function_name
  handler                        = "uk.gov.nationalarchives.signcookies.Lambda::handleRequest"
  role                           = aws_iam_role.sign_cookies_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/sign-cookies.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      PRIVATE_KEY = aws_kms_ciphertext.environment_vars_sign_cookies["private_key"].ciphertext_blob
      ENVIRONMENT = aws_kms_ciphertext.environment_vars_sign_cookies["environment"].ciphertext_blob
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_sign_cookies_security_group.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }

  depends_on = [var.mount_target_zero, var.mount_target_one]
}

resource "aws_kms_ciphertext" "environment_vars_sign_cookies" {
  for_each  = local.count_sign_cookies == 0 ? {} : { private_key = data.aws_ssm_parameter.cloudfront_private_key[0].value, environment = local.environment }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.sign_cookies_function_name }
}

resource "aws_cloudwatch_log_group" "sign_cookies_lambda_log_group" {
  count = local.count_sign_cookies
  name  = "/aws/lambda/${aws_lambda_function.sign_cookies_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "sign_cookies_lambda_policy" {
  count  = local.count_sign_cookies
  policy = templatefile("${path.module}/templates/sign_cookies_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id, environment = local.environment, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}SignCookiesLambdaPolicy"
}

resource "aws_iam_role" "sign_cookies_lambda_iam_role" {
  count              = local.count_sign_cookies
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}SignCookiesLambdaRole"
}

resource "aws_iam_role_policy_attachment" "sign_cookies_lambda_role_policy" {
  count      = local.count_sign_cookies
  policy_arn = aws_iam_policy.sign_cookies_lambda_policy.*.arn[0]
  role       = aws_iam_role.sign_cookies_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_sign_cookies_security_group" {
  count       = local.count_sign_cookies
  name        = "${var.project}-lambda-sign_cookies"
  description = "Signed Cookies Lambda Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-sign-cookies" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_sign_cookies_rule" {
  count             = local.count_sign_cookies
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sign_cookies_security_group[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_lambda_permission" "sign_cookies_lambda_permissions" {
  count         = local.count_sign_cookies
  statement_id  = "AllowExecutionFromSignedCookiesApi"
  action        = "lambda:InvokeFunction"
  function_name = local.sign_cookies_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_arn}/*/GET/cookies"
}
