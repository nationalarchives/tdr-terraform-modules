resource "aws_lambda_function" "disable_keycloak_users_api_lambda_function" {
  count                          = local.count_disable_keycloak_users_api
  function_name                  = local.disable_keycloak_user_api_function_name
  handler                        = "uk.gov.nationalarchives.keycloak.users.DisableKeycloakUsersLambda::handleRequest"
  role                           = aws_iam_role.disable_keycloak_users_api_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/disable-keycloak-user-api.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      AUTH_URL                      = aws_kms_ciphertext.environment_vars_disable_keycloak_users_api["auth_url"].ciphertext_blob
      USER_ADMIN_CLIENT_SECRET      = aws_kms_ciphertext.environment_vars_disable_keycloak_users_api["user_admin_client_secret"].ciphertext_blob
      USER_ADMIN_CLIENT_SECRET_PATH = var.user_admin_client_secret_path
      REPORTING_CLIENT_SECRET       = aws_kms_ciphertext.environment_vars_disable_keycloak_users_api["reporting_client_secret"].ciphertext_blob
      REPORTING_CLIENT_SECRET_PATH  = var.reporting_client_secret_path
    }
  }
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.allow_outbound_lambda_create_keycloak_users_api.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_disable_keycloak_users_api" {
  for_each  = local.count_disable_keycloak_users_api == 0 ? {} : { user_admin_client_secret = var.user_admin_client_secret, auth_url = var.auth_url, reporting_client_secret = var.reporting_client_secret }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.disable_keycloak_user_api_function_name }
}

resource "aws_cloudwatch_log_group" "disable_keycloak_users_api_lambda_log_group" {
  count             = local.count_disable_keycloak_users_api
  name              = "/aws/lambda/${aws_lambda_function.disable_keycloak_users_api_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "disable_keycloak_users_api_lambda_policy" {
  count  = local.count_disable_keycloak_users_api
  policy = templatefile("${path.module}/templates/disable_keycloak_users_api_lambda.json.tpl", { function_name = local.create_keycloak_user_api_function_name, account_id = data.aws_caller_identity.current.account_id, kms_arn = var.kms_key_arn, parameter_name = var.user_admin_client_secret_path })
  name   = "${upper(var.project)}DisableKeycloakUsersApiPolicy${title(local.environment)}"
}

resource "aws_iam_role" "disable_keycloak_users_api_lambda_iam_role" {
  count              = local.count_disable_keycloak_users_api
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}DisableKeycloakUsersApiRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "disable_keycloak_users_api_lambda_role_policy" {
  count      = local.count_disable_keycloak_users_api
  policy_arn = aws_iam_policy.disable_keycloak_users_api_lambda_policy.*.arn[0]
  role       = aws_iam_role.disable_keycloak_users_api_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "allow_outbound_lambda_disable_keycloak_users_api" {
  count       = local.count_disable_keycloak_users_api
  name        = "allow-outbound-disable-users-api"
  description = "Allow outbound traffic for the disable users lambda"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-allow-outbound-disable-users-api" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_disable_keycloak_users_api_rule" {
  count             = local.count_disable_keycloak_users_api
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_outbound_lambda_disable_keycloak_users_api[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lambda_permission" "scheduled_event_permission" {
  count         = local.count_disable_keycloak_users_api
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = local.disable_keycloak_user_api_function_name
  principal     = "events.amazonaws.com"
  source_arn    = "${var.scheduled_disable_judgment_arn}/*"
}
