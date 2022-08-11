output "database_password" {
  value = aws_db_instance.db_instance.password
}

output "database_user" {
  value = aws_db_instance.db_instance.username
}

output "database_url" {
  value = aws_db_instance.db_instance.address
}
