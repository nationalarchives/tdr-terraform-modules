data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "mgmt_account_number" {
  count = var.project == "tdr" ? 1 : 0
  name  = "/mgmt/management_account"
}

data "aws_ssm_parameter" "intg_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/intg_account"
}

data "aws_ssm_parameter" "staging_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/staging_account"
}

data "aws_ssm_parameter" "prod_account_number" {
  count = var.project == "tdr" && local.environment == "mgmt" ? 1 : 0
  name  = "/mgmt/prod_account"
}

data "aws_ssm_parameter" "cloudfront_private_key_pem" {
  count = var.project == "tdr" && local.environment != "mgmt" && local.environment != "sbox" ? 1 : 0
  name  = "/${local.environment}/cloudfront/key/private/pem"
}

data "aws_availability_zones" "available" {}

data "aws_organizations_organization" "current" {}

// This replaces the templates/lambda_assume_role.json.tpl which did not have a trust condition
// See TDRD-845
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {

    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = ["${data.aws_organizations_organization.current.id}"]
    }
  }
}
