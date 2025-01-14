resource "aws_lambda_function" "rotate_keycloak_secrets_lambda_function" {
  count                          = local.count_rotate_keycloak_secrets
  function_name                  = local.rotate_keycloak_secrets_function_name
  handler                        = "uk.gov.nationalarchives.rotate.Lambda::handleRequest"
  role                           = aws_iam_role.rotate_keycloak_secrets_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/rotate-keycloak-secrets.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      AUTH_URL                       = var.auth_url
      AUTH_SECRET_PATH               = var.rotate_secrets_client_path
      ENVIRONMENT                    = local.environment
      SNS_TOPIC                      = var.notifications_topic
      CONSIGNMENT_API_CONNECTION_ARN = var.api_connection_arn
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_rotate_keycloak_secrets_security_group.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "rotate_keycloak_secrets_lambda_log_group" {
  count             = local.count_rotate_keycloak_secrets
  name              = "/aws/lambda/${aws_lambda_function.rotate_keycloak_secrets_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "rotate_keycloak_secrets_lambda_policy" {
  count = local.count_rotate_keycloak_secrets
  policy = templatefile("${path.module}/templates/rotate_keycloak_secrets_policy.json.tpl", {
    account_id         = data.aws_caller_identity.current.account_id,
    environment        = local.environment,
    kms_arn            = var.kms_key_arn
    api_connection_arn = var.api_connection_arn
  })
  name = "${upper(var.project)}RotateKeycloakSecretsLambdaPolicy${title(local.environment)}"
}

resource "aws_iam_role" "rotate_keycloak_secrets_lambda_iam_role" {
  count              = local.count_rotate_keycloak_secrets
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}RotateKeycloakSecretsLambdaRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "rotate_keycloak_secrets_lambda_role_policy" {
  count      = local.count_rotate_keycloak_secrets
  policy_arn = aws_iam_policy.rotate_keycloak_secrets_lambda_policy.*.arn[0]
  role       = aws_iam_role.rotate_keycloak_secrets_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_rotate_keycloak_secrets_security_group" {
  count       = local.count_rotate_keycloak_secrets
  name        = "${var.project}-lambda-rotate_keycloak_secrets"
  description = "Rotate Keycloak Secrets Lambda Security Group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-lambda-rotate-keycloak-secrets" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_rotate_keycloak_secrets_rule" {
  count             = local.count_rotate_keycloak_secrets
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_rotate_keycloak_secrets_security_group[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lambda_permission" "rotate_secrets_lambda_allow_event" {
  count         = local.count_rotate_keycloak_secrets
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotate_keycloak_secrets_lambda_function[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.rotate_keycloak_secrets_event_arn
}
