locals {
  key_count  = var.public_key == "" ? 0 : 1
  role_count = var.role_name == "" ? 1 : 0
  role_name  = local.role_count == 0 ? var.role_name : aws_iam_role.ec2_role[0].name
}
