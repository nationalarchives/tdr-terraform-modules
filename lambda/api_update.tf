resource "aws_lambda_function" "lambda_api_update_function" {
  count                          = local.count_api_update
  function_name                  = local.api_update_function_name
  handler                        = "uk.gov.nationalarchives.api.update.Lambda::update"
  role                           = aws_iam_role.lambda_api_update_iam_role.*.arn[0]
  runtime                        = "java11"
  filename                       = "${path.module}/functions/api-update.jar"
  timeout                        = var.timeout_seconds
  memory_size                    = 512
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags
  environment {
    variables = {
      CLIENT_SECRET_PATH = var.backend_checks_client_secret_path
      API_URL            = aws_kms_ciphertext.environment_vars_api_update["api_url"].ciphertext_blob
      AUTH_URL           = aws_kms_ciphertext.environment_vars_api_update["auth_url"].ciphertext_blob
      CLIENT_ID          = aws_kms_ciphertext.environment_vars_api_update["client_id"].ciphertext_blob
      CLIENT_SECRET      = aws_kms_ciphertext.environment_vars_api_update["client_secret"].ciphertext_blob
      QUEUE_URL          = aws_kms_ciphertext.environment_vars_api_update["queue_url"].ciphertext_blob
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_api_update.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}
resource "aws_kms_ciphertext" "environment_vars_api_update" {
  for_each  = local.count_api_update == 0 ? {} : { api_url = "${var.api_url}/graphql", auth_url = var.auth_url, client_id = "tdr-backend-checks", client_secret = var.keycloak_backend_checks_client_secret, queue_url = local.api_update_queue_url }
  key_id    = var.kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = local.api_update_function_name }
}

resource "aws_lambda_event_source_mapping" "api_update_sqs_queue_mapping" {
  count            = local.count_api_update
  event_source_arn = local.api_update_queue
  function_name    = aws_lambda_function.lambda_api_update_function.*.arn[0]
  batch_size       = 1
}

resource "aws_cloudwatch_log_group" "lambda_api_update_log_group" {
  count = local.count_api_update
  name  = "/aws/lambda/${aws_lambda_function.lambda_api_update_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "lambda_api_update_policy" {
  count  = local.count_api_update
  policy = templatefile("${path.module}/templates/api_update.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id, input_sqs_arn = local.api_update_queue, kms_arn = var.kms_key_arn })
  name   = "${upper(var.project)}ApiUpdatePolicy"
}

resource "aws_iam_role" "lambda_api_update_iam_role" {
  count              = local.count_api_update
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ApiUpdateRole"
}

resource "aws_iam_role_policy_attachment" "lambda_api_update_role_policy" {
  count      = local.count_api_update
  policy_arn = aws_iam_policy.lambda_api_update_policy.*.arn[0]
  role       = aws_iam_role.lambda_api_update_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_api_update" {
  count       = local.count_api_update
  name        = "allow-https-outbound-api-update"
  description = "Allow HTTPS outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-allow-https-outbound-api-update" }
    )
  )
}

resource "aws_security_group_rule" "allow_https_lambda_api_update_rule" {
  count             = local.count_api_update
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_api_update[count.index].id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
