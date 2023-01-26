# ensures compliance with CIS AWS Foundation Benchmark
resource "aws_iam_account_password_policy" "cis_benchmark" {
  count                          = var.aws_account_level == true ? 1 : 0
  minimum_password_length        = 14
  max_password_age               = 90
  password_reuse_prevention      = 24
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_policy" "manage_credentials" {
  name   = "TDRIAMUserManageCredentialsPolicy${title(var.environment)}"
  policy = templatefile("${path.module}/templates/iam_user_manage_credentials.json.tpl", {})
}

# ensures compliance with CIS AWS Foundation Benchmark requirement for support role to be attached
resource "aws_iam_group" "support" {
  count = var.aws_account_level == true ? 1 : 0
  name  = var.support_group
  path  = "/group/"
}

# ensures compliance with CIS AWS Foundation Benchmark requirement for support role to be attached
resource "aws_iam_group_policy_attachment" "support_policy_attach" {
  count      = var.aws_account_level == true ? 1 : 0
  group      = aws_iam_group.support.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}

# group with permissions to undertake security audit and penetration testing tasks
resource "aws_iam_group" "security_audit" {
  count = var.security_audit == true ? 1 : 0
  name  = var.security_audit_group
  path  = "/group/"
}

resource "aws_iam_group_policy_attachment" "security_audit_policy_attach" {
  count      = var.security_audit == true ? 1 : 0
  group      = aws_iam_group.security_audit.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_group_policy_attachment" "read_only_policy_attach" {
  count      = var.security_audit == true ? 1 : 0
  group      = aws_iam_group.security_audit.*.name[0]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "manage_credentials" {
  count      = var.security_audit == true ? 1 : 0
  group      = aws_iam_group.security_audit.*.name[0]
  policy_arn = aws_iam_policy.manage_credentials.arn
}

