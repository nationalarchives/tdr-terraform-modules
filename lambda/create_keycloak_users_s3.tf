resource "aws_lambda_function" "create_keycloak_users_s3_lambda_function" {
  count                          = local.count_create_keycloak_users_s3
  function_name                  = local.create_keycloak_user_s3_function_name
  handler                        = "uk.gov.nationalarchives.keycloak.users.CSVLambda::handleRequest"
  role                           = aws_iam_role.create_keycloak_users_s3_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/create-keycloak-user-s3.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      AUTH_URL                      = aws_kms_ciphertext.environment_vars_create_keycloak_users_s3["auth_url"].ciphertext_blob
      USER_ADMIN_CLIENT_SECRET      = aws_kms_ciphertext.environment_vars_create_keycloak_users_s3["user_admin_client_secret"].ciphertext_blob
      USER_ADMIN_CLIENT_SECRET_PATH = var.user_admin_client_secret_path
    }
  }
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.allow_outbound_lambda_create_keycloak_users_s3.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "create_keycloak_users_s3_lambda_permissions" {
  count         = local.count_create_keycloak_users_s3
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_keycloak_users_s3_lambda_function[count.index].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_kms_ciphertext" "environment_vars_create_keycloak_users_s3" {
  for_each  = local.count_create_keycloak_users_s3 == 0 ? {} : { user_admin_client_secret = var.user_admin_client_secret, auth_url = var.auth_url }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.create_keycloak_user_s3_function_name }
}

resource "aws_cloudwatch_log_group" "create_keycloak_users_s3_lambda_log_group" {
  count = local.count_create_keycloak_users_s3
  name  = "/aws/lambda/${aws_lambda_function.create_keycloak_users_s3_lambda_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "create_keycloak_users_s3_lambda_policy" {
  count  = local.count_create_keycloak_users_s3
  policy = templatefile("${path.module}/templates/create_keycloak_users_s3_lambda.json.tpl", { function_name = local.create_keycloak_user_s3_function_name, account_id = data.aws_caller_identity.current.account_id, kms_arn = var.kms_key_arn, environment = local.environment })
  name   = "${upper(var.project)}CreateKeycloakUsersS3Policy${title(local.environment)}"
}

resource "aws_iam_role" "create_keycloak_users_s3_lambda_iam_role" {
  count              = local.count_create_keycloak_users_s3
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}CreateKeycloakUsersS3Role${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "create_keycloak_users_s3_lambda_role_policy" {
  count      = local.count_create_keycloak_users_s3
  policy_arn = aws_iam_policy.create_keycloak_users_s3_lambda_policy.*.arn[0]
  role       = aws_iam_role.create_keycloak_users_s3_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "allow_outbound_lambda_create_keycloak_users_s3" {
  count       = local.count_create_keycloak_users_s3
  name        = "allow-outbound-create-users-s3"
  description = "Allow outbound traffic for the create users lambda"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-allow-outbound-create-users-s3" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_create_keycloak_users_s3_rule" {
  count             = local.count_create_keycloak_users_s3
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.allow_outbound_lambda_create_keycloak_users_s3[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
