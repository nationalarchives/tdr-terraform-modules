output "database_url" {
  value = aws_db_instance.db_instance.address
}

output "resource_id" {
  value = aws_db_instance.db_instance.resource_id
}

output "database_master_user_secret_arn" {
  value = aws_db_instance.db_instance.master_user_secret[0].secret_arn
}
