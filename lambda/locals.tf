locals {
  workspace           = lower(terraform.workspace)
  environment         = local.workspace == "default" ? "mgmt" : local.workspace
  count_av_yara       = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  count_log_data      = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_log_data_mgmt = var.apply_resource == true && var.lambda_log_data == true && local.environment == "mgmt" ? 1 : 0
}