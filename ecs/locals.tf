locals {
  ecs_account_number      = local.environment == "sbox" ? data.aws_caller_identity.current.account_id : data.aws_ssm_parameter.mgmt_account_number.value
  count_file_format_build = var.file_format_build == true ? 1 : 0
  count_grafana_build     = var.grafana_build == true ? 1 : 0
  count_jenkins           = var.jenkins == true ? 1 : 0
  count_plugin_updates    = var.plugin_updates == true ? 1 : 0
  count_npm               = var.npm == true ? 1 : 0
  count_sbt_with_postgres = var.sbt_with_postgres == true ? 1 : 0
  environment             = local.workspace == "default" ? "mgmt" : local.workspace
  project_prefix          = upper(var.project)
  workspace               = lower(terraform.workspace)
}
