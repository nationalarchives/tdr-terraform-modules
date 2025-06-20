resource "aws_lambda_function" "create_db_users_lambda_function" {
  count                          = local.count_create_db_users
  function_name                  = local.create_db_users_function_name
  handler                        = "uk.gov.nationalarchives.db.users.Lambda::process"
  role                           = aws_iam_role.create_db_users_lambda_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/create-db-users.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 1024
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      DB_SECRETS_ARN = aws_kms_ciphertext.environment_vars_create_db_users["db_secrets_arn"].ciphertext_blob
      DB_URL         = aws_kms_ciphertext.environment_vars_create_db_users["db_url"].ciphertext_blob
      DATABASE_NAME  = aws_kms_ciphertext.environment_vars_create_db_users["database_name"].ciphertext_blob
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.create_db_users_lambda.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_kms_ciphertext" "environment_vars_create_db_users" {
  for_each  = local.count_create_db_users == 0 ? {} : { db_secrets_arn = var.db_secrets_arn, db_url = "jdbc:postgresql://${var.db_url}:5432/${var.database_name == "keycloak" ? var.database_name : "consignmentapi"}", database_name = var.database_name }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.create_db_users_function_name }
}

resource "aws_cloudwatch_log_group" "create_db_users_lambda_log_group" {
  count             = local.count_create_db_users
  name              = "/aws/lambda/${aws_lambda_function.create_db_users_lambda_function.*.function_name[0]}"
  retention_in_days = var.cloudwatch_log_retention_in_days
  tags              = var.common_tags
}

resource "aws_iam_policy" "create_db_users_lambda_policy" {
  count  = local.count_create_db_users
  policy = templatefile("${path.module}/templates/create_db_users_lambda.json.tpl", { lambda_name = var.lambda_name, environment = local.environment, account_id = data.aws_caller_identity.current.account_id, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}CreateDbUsers${title(var.database_name)}Policy${title(local.environment)}"
}

resource "aws_iam_role" "create_db_users_lambda_iam_role" {
  count              = local.count_create_db_users
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  name               = "${upper(var.project)}CreateDbUsers${title(var.database_name)}Role${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "create_db_users_lambda_role_policy" {
  count      = local.count_create_db_users
  policy_arn = aws_iam_policy.create_db_users_lambda_policy.*.arn[0]
  role       = aws_iam_role.create_db_users_lambda_iam_role.*.name[0]
}

resource "aws_security_group" "create_db_users_lambda" {
  count       = local.count_create_db_users
  name        = "create-db-users-${var.database_name}-lambda-security-group"
  description = "Allow access to the database"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-create-db-users-lambda-security-group" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_create_db_users_rule" {
  count             = local.count_create_db_users
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.create_db_users_lambda[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "create_db_user_db_rule" {
  count                    = local.count_create_db_users
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.create_db_users_lambda[count.index].id
  to_port                  = 5432
  type                     = "egress"
  source_security_group_id = var.database_security_group
}
