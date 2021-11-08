resource "random_password" "password" {
  length  = 16
  special = false
}

resource "random_string" "snapshot_prefix" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_db_subnet_group" "user_subnet_group" {
  name       = "${var.database_name}-main-${var.environment}"
  subnet_ids = var.private_subnets

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "user-db-subnet-group-${var.environment}" }
    )
  )
}

resource "aws_rds_cluster" "database" {
  cluster_identifier_prefix       = "keycloak-db-postgres-${var.environment}"
  engine                          = var.engine
  engine_version                  = var.engine_version
  availability_zones              = var.database_availability_zones
  database_name                   = var.database_name
  master_username                 = var.admin_username
  master_password                 = random_password.password.result
  final_snapshot_identifier       = "${var.database_name}-db-final-snapshot-${random_string.snapshot_prefix.result}-${var.environment}"
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_id
  vpc_security_group_ids          = var.security_group_ids
  db_subnet_group_name            = aws_db_subnet_group.user_subnet_group.name
  enabled_cloudwatch_logs_exports = var.cloudwatch_log_exports
  backup_retention_period         = 7
  deletion_protection             = true
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.database_name}-db-cluster-${var.environment}" }
    )
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to availability zones because AWS automatically adds the
      # extra availability zone "eu-west-2c", which is rejected by the API as
      # unavailable if specified directly.
      availability_zones,
    ]
  }
}

resource "aws_rds_cluster_instance" "user_database_instance" {
  count                = var.instance_count
  identifier_prefix    = "${var.database_name}-instance-${var.environment}"
  cluster_identifier   = aws_rds_cluster.database.id
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_subnet_group_name = aws_db_subnet_group.user_subnet_group.name
}

# Will take the /new out of the name once the old resources are destroyed
resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.environment}/${var.database_name}/new/database/url"
  type  = "SecureString"
  value = aws_rds_cluster.database.endpoint
}
