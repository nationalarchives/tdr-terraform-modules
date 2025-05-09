
resource "random_string" "identifier_string" {
  length  = 10
  special = false
  upper   = false
}

resource "aws_db_subnet_group" "user_subnet_group" {
  name       = "${var.database_name}-instance-main-${var.environment}"
  subnet_ids = var.private_subnets

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "user-db-subnet-group-${var.environment}" }
    )
  )
}

resource "aws_db_instance" "db_instance" {
  instance_class                        = var.instance_class
  db_name                               = var.database_name
  identifier                            = "${var.database_name}-${random_string.identifier_string.result}"
  storage_encrypted                     = true
  kms_key_id                            = var.kms_key_id
  allocated_storage                     = 60
  engine                                = "postgres"
  engine_version                        = var.database_version
  username                              = var.admin_username
  vpc_security_group_ids                = var.security_group_ids
  db_subnet_group_name                  = aws_db_subnet_group.user_subnet_group.name
  multi_az                              = var.multi_az
  availability_zone                     = var.multi_az == true ? null : var.availability_zone
  auto_minor_version_upgrade            = true
  tags                                  = merge(var.common_tags, var.aws_backup_tag)
  iam_database_authentication_enabled   = true
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports       = ["postgresql"]
  deletion_protection                   = true
  backup_retention_period               = var.backup_retention_period
  ca_cert_identifier                    = var.ca_cert_identifier
  apply_immediately                     = var.apply_immediately
  manage_master_user_password           = true
}

resource "aws_ssm_parameter" "database_username" {
  name  = "/${var.environment}/${var.database_name}/instance/username"
  type  = "SecureString"
  value = aws_db_instance.db_instance.username
}

resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.environment}/${var.database_name}/instance/url"
  type  = "SecureString"
  value = aws_db_instance.db_instance.address
}
