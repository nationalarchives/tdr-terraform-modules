data "template_file" "npm_template" {
  count    = local.count_npm
  template = file("${path.module}/templates/jenkins_sign_commits.json.tpl")

  vars = {
    account = data.aws_caller_identity.current.account_id,
    name    = "npm"
  }
}

resource "aws_ecs_task_definition" "npm_task" {
  count                    = local.count_npm
  container_definitions    = data.template_file.npm_template[count.index].rendered
  family                   = "npm"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TDRJenkinsPublishRole"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TDRJenkinsBuildNpmExecutionRole"
}
