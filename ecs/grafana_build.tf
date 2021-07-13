locals {
  app_port = 3000
}

data "aws_ssm_parameter" "database_url" {
  count = local.count_grafana_build
  name  = "/${local.environment}/grafana/database/url"
}

data "aws_ssm_parameter" "database_user" {
  count = local.count_grafana_build
  name  = "/${local.environment}/grafana/database/username"
}

data "aws_ssm_parameter" "database_password" {
  count = local.count_grafana_build
  name  = "/${local.environment}/grafana/database/password"
}

resource "random_password" "grafana_password" {
  count   = local.count_grafana_build
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "grafana_admin_password" {
  count = local.count_grafana_build
  name  = "/${local.environment}/${var.app_name}/admin/password"
  type  = "SecureString"
  value = random_password.grafana_password[count.index].result
}

resource "aws_ssm_parameter" "grafana_admin_user" {
  count = local.count_grafana_build
  name  = "/${local.environment}/${var.app_name}/admin/user"
  type  = "SecureString"
  value = "${var.project}-${var.app_name}-admin-${local.environment}"
}

resource "aws_ecs_cluster" "grafana_ecs" {
  count = local.count_grafana_build
  name  = "${var.app_name}-${local.environment}"

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-${var.app_name}-${local.environment}" }
    )
  )
}

resource "aws_ecs_task_definition" "grafana_task" {
  count                    = local.count_grafana_build
  family                   = "${var.app_name}-build-${local.environment}"
  execution_role_arn       = aws_iam_role.grafana_ecs_execution[count.index].arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  container_definitions = templatefile(
    "${path.module}/templates/grafana_build.json.tpl",
    {
      admin_user             = aws_ssm_parameter.grafana_admin_user[count.index].name
      admin_user_password    = aws_ssm_parameter.grafana_admin_password[count.index].name
      app_image              = "grafana/grafana:latest"
      app_port               = local.app_port
      app_environment        = local.environment
      aws_region             = var.aws_region
      database_host_path     = data.aws_ssm_parameter.database_url[count.index].name
      database_user_path     = data.aws_ssm_parameter.database_user[count.index].name
      database_password_path = data.aws_ssm_parameter.database_password[count.index].name
      database_type          = var.grafana_database_type
      domain_name            = var.domain_name
      log_group_name         = aws_cloudwatch_log_group.grafana_build_log_group[count.index].name
      project                = var.project
      server_protocol        = "http"
    }
  )
  task_role_arn = aws_iam_role.grafana_ecs_task[count.index].arn

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.app_name}-task-definition-${local.environment}" }
    )
  )
}

resource "aws_ecs_service" "grafana_service" {
  count                             = local.count_grafana_build
  name                              = "${var.app_name}-service-${local.environment}"
  cluster                           = aws_ecs_cluster.grafana_ecs[count.index].id
  task_definition                   = aws_ecs_task_definition.grafana_task[count.index].arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = "360"

  network_configuration {
    security_groups  = [var.ecs_task_security_group_id]
    subnets          = var.vpc_private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.project}-${var.app_name}"
    container_port   = local.app_port
  }

  depends_on = [var.alb_target_group_arn]
}

resource "aws_iam_role" "grafana_ecs_execution" {
  count              = local.count_grafana_build
  name               = "${local.project_prefix}GrafanaAppExecutionRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.app_name}-ecs-execution-iam-role-${local.environment}" }
    )
  )
}

resource "aws_iam_role" "grafana_ecs_task" {
  count              = local.count_grafana_build
  name               = "${local.project_prefix}GrafanaAppTaskRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.app_name}-ecs-task-iam-role-${local.environment}" }
    )
  )
}

resource "aws_iam_policy" "ecs_logs_policy" {
  count = local.count_grafana_build
  name  = "${local.project_prefix}GrafanaEcsExecutionPolicy${title(local.environment)}"
  policy = templatefile(
    "${path.module}/templates/ecs_logs_policy.json.tpl",
    {
      log_group_arn = aws_cloudwatch_log_group.grafana_build_log_group[count.index].arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_logs" {
  count      = local.count_grafana_build
  role       = aws_iam_role.grafana_ecs_execution[count.index].name
  policy_arn = aws_iam_policy.ecs_logs_policy[count.index].arn
}

resource "aws_iam_role_policy_attachment" "grafana_ecs_execution_ssm" {
  count      = local.count_grafana_build
  role       = aws_iam_role.grafana_ecs_execution[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_cloudwatch_log_group" "grafana_build_log_group" {
  count             = local.count_grafana_build
  name              = "/ecs/${var.app_name}-build-${local.environment}"
  retention_in_days = 30
}
