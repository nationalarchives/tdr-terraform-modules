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
  value = aws_iam_role.ec2_role.id
}

output "private_dns" {
  value = aws_instance.instance.private_dns
}
