output "database_password" {
  value = aws_db_instance.db_instance.password
}

output "database_user" {
  value = aws_db_instance.db_instance.username
}

output "database_url" {
  value = aws_db_instance.db_instance.address
}

output "resource_id" {
  value = aws_db_instance.db_instance.resource_id
}

output "database_master_user_secret_arn" {
  value = var.manage_master_credentials_with_secrets_manager ? join("", aws_db_instance.db_instance.master_user_secret.*.secret_arn) : null
}
