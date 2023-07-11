resource "aws_iam_openid_connect_provider" "openid_provider" {
  client_id_list  = [var.audience]
  thumbprint_list = var.thumbprint_list
  url             = var.url
  tags            = var.common_tags
}
