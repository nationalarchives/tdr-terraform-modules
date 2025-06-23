locals {
  role_name = "TDR${var.step_function_name}Role${title(var.environment)}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_sfn_state_machine" "state_machine" {
  definition = var.definition
  name       = "${upper(var.project)}${var.step_function_name}${title(var.environment)}"
  role_arn   = aws_iam_role.state_machine_role.arn
  tags       = var.tags
  tracing_configuration {
    enabled = true
  }
}


resource "aws_iam_role" "state_machine_role" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.step_function_iam_trust_policy.json
  tags = merge(
    var.tags,
    tomap(
      { "Name" = local.role_name }
    )
  )
}

resource "aws_iam_policy" "state_machine_policy" {
  name   = "TDR${var.step_function_name}Policy${title(var.environment)}"
  policy = var.policy
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "state_machine_attachment" {
  policy_arn = aws_iam_policy.state_machine_policy.arn
  role       = aws_iam_role.state_machine_role.id
}

// See TDRD-845
// See https://docs.aws.amazon.com/step-functions/latest/dg/procedure-create-iam-role.html
// Note using aws_sfn_state_machine.state_machine.arn creates a cyclic dependancy so cannot be used
data "aws_iam_policy_document" "step_function_iam_trust_policy" {
  statement {

    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    # TODO
    # This breaks the step function when a map run is used
    # Needs investigting.  Have tried usind the mapRun arn but to no avail
    # condition {
    #   test     = "ArnLike"
    #   variable = "aws:SourceArn"
    #   values   = ["arn:${data.aws_partition.current.id}:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:stateMachine:${upper(var.project)}${var.step_function_name}${title(var.environment)}"]
    # }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.id}"]
    }
  }
}
