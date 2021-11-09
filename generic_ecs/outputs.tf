output "task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task.arn
}

output "cluster_arn" {
  value = aws_ecs_cluster.ecs_cluster.arn
}
