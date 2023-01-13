locals {
  role_name = "TDR${var.step_function_name}Role${title(var.environment)}"
}
resource "aws_sfn_state_machine" "state_machine" {
  definition = var.definition
  name       = "${upper(var.project)}${var.step_function_name}${title(var.environment)}"
  role_arn   = aws_iam_role.state_machine_role.arn
  tags       = var.tags
}

resource "aws_iam_role" "state_machine_role" {
  name               = local.role_name
  assume_role_policy = templatefile("${path.module}/../iam_role/templates/assume_role.json.tpl", {service = "states.amazonaws.com"})
  tags = merge(
    var.tags,
    tomap(
      { "Name" =  local.role_name}
    )
    )
}

resource "aws_iam_policy" "state_machine_policy" {
  name   = "TDR${var.step_function_name}Policy${title(var.environment)}"
  policy = var.policy
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "state_machine_attachment" {
  policy_arn = aws_iam_policy.state_machine_policy.arn
  role       = aws_iam_role.state_machine_role.id
}
