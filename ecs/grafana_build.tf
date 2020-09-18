locals {
  app_port = 3000
}

data "aws_ssm_parameter" "intg_account_id" {
  name = "/${local.environment}/intg_account"
}

data "aws_ssm_parameter" "prod_account_id" {
  name = "/${local.environment}/prod_account"
}

data "aws_ssm_parameter" "staging_account_id" {
  name = "/${local.environment}/staging_account"
}

resource "random_password" "grafana_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "grafana_admin_password" {
  name  = "/${local.environment}/grafana/admin/password"
  type  = "SecureString"
  value = random_password.grafana_password.result
}

resource "aws_ssm_parameter" "grafana_admin_user" {
  name  = "/${local.environment}/grafana/admin/user"
  type  = "SecureString"
  value = "${var.project}-grafana-admin-${local.environment}"
}

resource "aws_ecs_cluster" "grafana_ecs" {
  name = "grafana-${local.environment}"

  tags = merge(
    var.common_tags,
    map("Name", "${var.project}-grafana-${local.environment}")
  )
}

resource "aws_ecs_task_definition" "grafana_task" {
  count                    = local.count_grafana_build
  family                   = "grafana-build-${local.environment}"
  execution_role_arn       = aws_iam_role.grafana_ecs_execution[count.index].arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 3072
  container_definitions = templatefile(
    "${path.module}/templates/grafana_build.json.tpl",
    {
      admin_user          = aws_ssm_parameter.grafana_admin_user.name
      admin_user_password = aws_ssm_parameter.grafana_admin_password.name
      app_image           = "grafana/grafana:latest"
      app_port            = local.app_port
      app_environment     = local.environment
      aws_region          = var.aws_region
      log_group_name      = aws_cloudwatch_log_group.grafana_build_log_group[count.index].name
      project             = var.project
    }
  )
  task_role_arn = aws_iam_role.grafana_ecs_task[count.index].arn

  tags = merge(
    var.common_tags,
    map("Name", "grafana-task-definition-${local.environment}")
  )
}

resource "aws_ecs_service" "grafana_service" {
  count                             = local.count_grafana_build
  name                              = "grafana-service-${local.environment}"
  cluster                           = aws_ecs_cluster.grafana_ecs.id
  task_definition                   = aws_ecs_task_definition.grafana_task[count.index].arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = "360"

  network_configuration {
    security_groups  = [data.aws_security_group.ecs_task_security_group.id]
    subnets          = data.aws_subnet_ids.private.ids
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
    map(
      "Name", "grafana-ecs-execution-iam-role-${local.environment}",
    )
  )
}

resource "aws_iam_role" "grafana_ecs_task" {
  count              = local.count_grafana_build
  name               = "${local.project_prefix}GrafanaAppTaskRole${title(local.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ecs_assume_role_policy.json.tpl", {})

  tags = merge(
    var.common_tags,
    map(
      "Name", "grafana-ecs-task-iam-role-${local.environment}",
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

resource "aws_iam_policy" "assume_grafana_env_monitoring_roles" {
  count = local.count_grafana_build
  name  = "${local.project_prefix}GrafanaEnvMonitoringAssumeRoles"
  policy = templatefile(
    "${path.module}/templates/grafana_assume_env_monitoring_roles_policy.json.tpl",
    {
      intg_account_id    = data.aws_ssm_parameter.intg_account_id.value,
      prod_account_id    = data.aws_ssm_parameter.prod_account_id.value,
      project_prefix     = local.project_prefix
      staging_account_id = data.aws_ssm_parameter.staging_account_id.value
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

resource "aws_iam_role_policy_attachment" "grafana_env_monitoring" {
  count      = local.count_grafana_build
  role       = aws_iam_role.grafana_ecs_task[count.index].name
  policy_arn = aws_iam_policy.assume_grafana_env_monitoring_roles[count.index].arn
}

resource "aws_cloudwatch_log_group" "grafana_build_log_group" {
  count             = local.count_grafana_build
  name              = "/ecs/grafana-build-${local.environment}"
  retention_in_days = 30
}
