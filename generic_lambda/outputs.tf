output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_iam_role.arn
}
