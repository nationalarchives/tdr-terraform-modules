resource "aws_ecs_cluster" "jenkins_cluster" {
  count = local.count_jenkins
  name  = "${var.name}-${local.environment}"

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "tdr-ecs-${var.name}" }
    )
  )
}

resource "aws_ecs_task_definition" "jenkins_task" {
  count                    = local.count_jenkins
  family                   = "${var.name}-${local.environment}"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "3072"
  container_definitions    = templatefile("${path.module}/templates/jenkins.json.tpl", { management_account = data.aws_caller_identity.current.account_id, region = var.aws_region, app_environment = local.environment, jenkins_log_group = aws_cloudwatch_log_group.tdr_jenkins_log_group[count.index].name, jenkins_repository_name = var.name })
  task_role_arn            = var.task_role_arn

  volume {
    name      = "docker_bin"
    host_path = "/usr/bin/docker"
  }

  volume {
    name      = "docker_run"
    host_path = "/var/run/docker"
  }

  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.name}-task-definition-${local.environment}" }
    )
  )
}

resource "aws_ecs_service" "jenkins" {
  count                             = local.count_jenkins
  name                              = "${var.name}-service-${local.environment}"
  cluster                           = aws_ecs_cluster.jenkins_cluster[count.index].id
  task_definition                   = aws_ecs_task_definition.jenkins_task[count.index].arn
  desired_count                     = 1
  launch_type                       = "EC2"
  health_check_grace_period_seconds = "360"

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.name}-${local.environment}"
    container_port   = 8080
  }
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "tdr_jenkins_log_group" {
  count             = local.count_jenkins
  name              = "/ecs/tdr-${var.name}-${local.environment}"
  retention_in_days = 30
}
