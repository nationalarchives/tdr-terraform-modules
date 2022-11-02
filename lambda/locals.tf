locals {
  workspace                                 = lower(terraform.workspace)
  environment                               = local.workspace == "default" ? "mgmt" : local.workspace
  count_av_yara                             = var.apply_resource == true && var.lambda_yara_av == true ? 1 : 0
  count_checksum                            = var.apply_resource == true && var.lambda_checksum == true ? 1 : 0
  count_log_data                            = var.apply_resource == true && var.lambda_log_data == true ? 1 : 0
  count_api_update                          = var.apply_resource && var.lambda_api_update == true ? 1 : 0
  count_file_format                         = var.apply_resource && var.lambda_file_format == true ? 1 : 0
  count_log_data_mgmt                       = var.apply_resource == true && var.lambda_log_data == true && local.environment == "mgmt" ? 1 : 0
  count_download_files                      = var.apply_resource == true && var.lambda_download_files == true ? 1 : 0
  count_notifications                       = var.apply_resource == true && var.lambda_ecr_scan_notifications == true ? 1 : 0
  count_ecr_scan                            = var.apply_resource == true && var.lambda_ecr_scan == true ? 1 : 0
  count_rotate_keycloak_secrets             = var.apply_resource == true && var.lambda_rotate_keycloak_secrets == true ? 1 : 0
  count_signed_cookies                      = var.apply_resource == true && var.lambda_signed_cookies == true ? 1 : 0
  count_export_status_update                = var.apply_resource == true && var.lambda_export_status_update == true ? 1 : 0
  count_reporting                           = var.apply_resource == true && var.lambda_reporting == true ? 1 : 0
  count_efs                                 = var.apply_resource == true && var.use_efs ? 1 : 0
  count_create_db_users                     = var.apply_resource == true && var.lambda_create_db_users ? 1 : 0
  count_create_keycloak_db_user             = var.apply_resource == true && var.lambda_create_keycloak_db_users ? 1 : 0
  count_create_keycloak_db_user_new         = var.apply_resource == true && var.lambda_create_keycloak_db_users_new ? 1 : 0
  count_export_api_authoriser               = var.apply_resource == true && var.lambda_export_authoriser == true ? 1 : 0
  count_service_unavailable                 = var.apply_resource == true && var.lambda_service_unavailable == true ? 1 : 0
  count_create_keycloak_users_api           = var.apply_resource == true && var.lambda_create_keycloak_user_api == true ? 1 : 0
  count_create_keycloak_users_s3            = var.apply_resource == true && var.lambda_create_keycloak_user_s3 == true ? 1 : 0
  api_update_function_name                  = "${var.project}-api-update-${local.environment}"
  checksum_function_name                    = "${var.project}-checksum-${local.environment}"
  create_db_users_function_name             = "${var.project}-${var.lambda_name}-${local.environment}"
  create_keycloak_db_user_function_name     = "${var.project}-create-keycloak-db-user-${local.environment}"
  create_keycloak_db_user_function_name_new = "${var.project}-create-keycloak-db-user-new-${local.environment}"
  download_files_function_name              = "${var.project}-download-files-${local.environment}"
  create_keycloak_user_api_function_name    = "${var.project}-create-keycloak-user-api-${local.environment}"
  create_keycloak_user_s3_function_name     = "${var.project}-create-keycloak-user-s3-${local.environment}"
  export_api_authoriser_function_name       = "${var.project}-export-api-authoriser-${local.environment}"
  export_status_update_function_name        = "${var.project}-export-status-update-${local.environment}"
  file_format_function_name                 = "${var.project}-file-format-${local.environment}"
  log_data_function_name                    = "${var.project}-log-data-${local.environment}"
  notifications_function_name               = "${var.project}-notifications-${local.environment}"
  sign_cookies_function_name                = "${var.project}-sign-cookies-${local.environment}"
  signed_cookies_function_name              = "${var.project}-signed-cookies-${local.environment}"
  reporting_function_name                   = "${var.project}-reporting-${local.environment}"
  rotate_keycloak_secrets_function_name     = "${var.project}-rotate-keycloak-secrets-${local.environment}"
  service_unavailable_function_name         = "${var.project}-service-unavailable-${local.environment}"
  yara_av_function_name                     = "${var.project}-yara-av-${local.environment}"
  api_update_queue_name                     = "${var.project}-api-update-${local.environment}"
  api_update_queue                          = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.api_update_queue_name}"
  api_update_queue_url                      = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${local.api_update_queue_name}"
  antivirus_queue                           = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.project}-antivirus-${local.environment}"
  antivirus_queue_url                       = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.project}-antivirus-${local.environment}"
  checksum_queue                            = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.project}-checksum-${local.environment}"
  checksum_queue_url                        = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.project}-checksum-${local.environment}"
  download_files_queue                      = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.project}-download-files-${local.environment}"
  download_files_queue_url                  = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.project}-download-files-${local.environment}"
  file_format_queue                         = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.project}-file-format-${local.environment}"
  file_format_queue_url                     = "https://sqs.${var.region}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.project}-file-format-${local.environment}"
  export_api_authoriser_arn                 = var.apply_resource == true && var.lambda_export_authoriser == true && length(aws_lambda_function.export_api_authoriser_lambda_function) > 0 ? aws_lambda_function.export_api_authoriser_lambda_function.*.arn[0] : ""
  signed_cookies_arn                        = var.apply_resource == true && var.lambda_signed_cookies == true && length(aws_lambda_function.signed_cookies_lambda_function) > 0 ? aws_lambda_function.signed_cookies_lambda_function.*.arn[0] : ""
  reporting_arn                             = var.apply_resource == true && var.lambda_reporting == true && length(aws_lambda_function.reporting_lambda_function) > 0 ? aws_lambda_function.reporting_lambda_function.*.arn[0] : ""
  create_keycloak_user_api_arn              = var.apply_resource == true && var.lambda_create_keycloak_user_api == true && length(aws_lambda_function.create_keycloak_users_api_lambda_function) > 0 ? aws_lambda_function.create_keycloak_users_api_lambda_function.*.arn[0] : ""
  create_keycloak_user_s3_arn               = var.apply_resource == true && var.lambda_create_keycloak_user_s3 == true && length(aws_lambda_function.create_keycloak_users_s3_lambda_function) > 0 ? aws_lambda_function.create_keycloak_users_s3_lambda_function.*.arn[0] : ""
  rotate_keycloak_secrets_arn               = var.apply_resource == true && var.lambda_rotate_keycloak_secrets == true && length(aws_lambda_function.rotate_keycloak_secrets_lambda_function) > 0 ? aws_lambda_function.rotate_keycloak_secrets_lambda_function.*.arn[0] : ""
  transform_engine_retry_queue_name         = "${var.project}-transform-engine-retry-${local.environment}"
  transform_engine_retry_queue              = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.transform_engine_retry_queue_name}"
  transform_engine_v2_out_queue_name        = "${var.project}-transform-engine-v2-retry-${local.environment}"
  transform_engine_v2_out_queue             = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.transform_engine_v2_out_queue_name}"
  principal_arns                            = setunion(var.sns_topic_arns, var.sqs_queue_arns)
}
