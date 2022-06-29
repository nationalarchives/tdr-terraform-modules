output "db_url_parameter_name" {
  value = aws_ssm_parameter.database_url.name
}

output "db_username" {
  value = aws_rds_cluster.database.master_username
}

output "db_password" {
  value = aws_rds_cluster.database.master_password
}

output "db_url" {
  value = aws_rds_cluster.database.endpoint
}

output "cluster_resource_id" {
  value = aws_rds_cluster.database.cluster_resource_id
}
