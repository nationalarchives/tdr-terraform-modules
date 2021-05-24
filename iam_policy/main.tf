resource "aws_iam_policy" "iam_policy" {
  name        = var.name
  policy      = var.policy_string
  description = var.description
}
