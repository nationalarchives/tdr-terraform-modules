output "file_format_build_sg_id" {
  value = aws_security_group.ecs_run_efs.*.id
}

output "grafana_ecs_task_role_name" {
  value = aws_iam_role.grafana_ecs_task.*.name
}

output "jenkins_cluster_arn" {
  value = var.jenkins == true ? aws_ecs_cluster.jenkins_cluster[0].arn : ""
}

output "file_format_build_role" {
  value = aws_iam_role.fileformat_ecs_task.*.arn
}
