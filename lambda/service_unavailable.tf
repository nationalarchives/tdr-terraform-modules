resource "aws_lambda_function" "lambda_service_unavailable_function" {
  count                          = local.count_service_unavailable
  function_name                  = local.service_unavailable_function_name
  handler                        = "app.lambda_handler"
  role                           = aws_iam_role.lambda_service_unavailable_iam_role.*.arn[0]
  runtime                        = "python3.8"
  filename                       = "${path.module}/functions/service-unavailable.zip"
  timeout                        = 3
  memory_size                    = 128
  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.common_tags

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = aws_security_group.lambda_service_unavailable.*.id
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "lambda_service_unavailable_log_group" {
  count = local.count_service_unavailable
  name  = "/aws/lambda/${aws_lambda_function.lambda_service_unavailable_function.*.function_name[0]}"
  tags  = var.common_tags
}

resource "aws_iam_policy" "lambda_service_unavailable_policy" {
  count  = local.count_service_unavailable
  policy = templatefile("${path.module}/templates/service_unavailable.json.tpl", { environment = local.environment, account_id = data.aws_caller_identity.current.account_id })
  name   = "${upper(var.project)}ServiceUnavailablePolicy${title(local.environment)}"
}

resource "aws_iam_role" "lambda_service_unavailable_iam_role" {
  count              = local.count_service_unavailable
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${upper(var.project)}ServiceUnavailableRole${title(local.environment)}"
}

resource "aws_iam_role_policy_attachment" "lambda_service_unavailable_role_policy" {
  count      = local.count_service_unavailable
  policy_arn = aws_iam_policy.lambda_service_unavailable_policy.*.arn[0]
  role       = aws_iam_role.lambda_service_unavailable_iam_role.*.name[0]
}

resource "aws_security_group" "lambda_service_unavailable" {
  count       = local.count_service_unavailable
  name        = "allow-https-outbound-service-unavailable"
  description = "Allow HTTPS outbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap(
      {
        "Name" = "${var.project}-allow-https-outbound-service-unavailable"
    })
  )
}

resource "aws_lambda_permission" "target_group_permission" {
  count         = local.count_service_unavailable
  statement_id  = "AllowExecutionFromFailoverTargetGroup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_service_unavailable_function[count.index].function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_alb_target_group.failover_target_group[count.index].arn
}

resource "random_string" "alb_prefix" {
  count   = local.count_service_unavailable
  length  = 4
  upper   = false
  special = false
}

resource "aws_alb_target_group_attachment" "alb_module" {
  count            = local.count_service_unavailable
  target_group_arn = aws_alb_target_group.failover_target_group[count.index].arn
  target_id        = aws_lambda_function.lambda_service_unavailable_function[count.index].arn
  depends_on       = [aws_lambda_permission.target_group_permission]
}

resource "aws_alb_target_group" "failover_target_group" {
  count = local.count_service_unavailable
  # name can't be longer than 32 characters
  name        = "${var.project}-su-${random_string.alb_prefix[count.index].result}-${local.environment}"
  protocol    = "HTTP"
  target_type = "lambda"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    tomap({
      "Name" = "${var.project}-service-unavailable-${random_string.alb_prefix[count.index].result}-${local.environment}"
    })
  )
}
