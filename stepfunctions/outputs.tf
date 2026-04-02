output "state_machine_arn" {
  value = aws_sfn_state_machine.state_machine.arn
}

output "step_function_role_name" {
  value = aws_iam_role.state_machine_role.name
}
