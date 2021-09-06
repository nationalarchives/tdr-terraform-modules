output "public_ip" {
  value = aws_instance.instance.public_ip
}

output "instance_arn" {
  value = aws_instance.instance.arn
}

output "instance_id" {
  value = aws_instance.instance.id
}

output "role_id" {
  value = length(aws_iam_role.ec2_role) == 0 ? "" : aws_iam_role.ec2_role[0].id
}

output "role_arn" {
  value = length(aws_iam_role.ec2_role) == 0 ? "" : aws_iam_role.ec2_role[0].arn
}

output "private_dns" {
  value = aws_instance.instance.private_dns
}
