variable "environment" {}

data "aws_caller_identity" "current" {}


resource "aws_api_gateway_account" "rest_api_account" {
  cloudwatch_role_arn = aws_iam_role.rest_api_cloudwatch_role.arn
  depends_on          = [aws_iam_role_policy_attachment.cloudwatch_policy_attachment]
}

resource "aws_iam_role" "rest_api_cloudwatch_role" {
  name               = "TDRApiGatewayCloudwatchRole${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/api_gateway_assume_role.json.tpl", {})
}

resource "aws_iam_policy" "rest_api_cloudwatch_policy" {
  name   = "TDRApiGatewayCloudwatchPolicy${title(var.environment)}"
  policy = templatefile("${path.module}/templates/api_cloudwatch_policy.json.tpl", { account_id = data.aws_caller_identity.current.account_id })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  policy_arn = aws_iam_policy.rest_api_cloudwatch_policy.arn
  role       = aws_iam_role.rest_api_cloudwatch_role.id
}
