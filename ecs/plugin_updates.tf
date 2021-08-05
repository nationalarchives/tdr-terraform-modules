data "template_file" "plugin_updates_template" {
  count    = local.count_plugin_updates
  template = file("${path.module}/templates/plugin_updates.json.tpl")

  vars = {
    account = data.aws_caller_identity.current.account_id
  }
}

resource "aws_ecs_task_definition" "plugin_updates_task" {
  count                    = local.count_plugin_updates
  container_definitions    = data.template_file.plugin_updates_template[count.index].rendered
  family                   = "plugin-updates"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TDRJenkinsPublishRole"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TDRJenkinsBuildPluginUpdatesExecutionRole"
}
