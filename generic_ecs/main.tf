resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.cluster_name }
    )
  )
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.task_family_name
  execution_role_arn       = var.execution_role
  network_mode             = "awsvpc"
  requires_compatibilities = var.compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = var.container_definition
  task_role_arn            = var.task_role

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.task_family_name }
    )
  )
}

resource "aws_ecs_service" "ecs_service" {
  name                              = var.service_name
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.ecs_task.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = var.health_check_grace_period

  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.alb_target_group_arn == "" ? [] : [{}]
    content {
      target_group_arn = var.alb_target_group_arn
      container_name   = var.container_name
      container_port   = var.load_balancer_container_port
    }
  }
}
