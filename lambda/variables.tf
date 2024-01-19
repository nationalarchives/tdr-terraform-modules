variable "region" {
  default = "eu-west-2"
}

variable "common_tags" {}

variable "project" {}

variable "apply_resource" {
  description = "use to conditionally apply resource from the calling module"
  default     = true
}

variable "timeout_seconds" {
  description = "The maximum time the function is allowed to run"
  type        = number
  default     = 180
}

variable "lambda_yara_av" {
  description = "deploy Lambda function to run yara av checks on files"
  default     = false
}

variable "lambda_checksum" {
  description = "deploy Lambda function to run the checksum calculation"
  default     = false
}

variable "lambda_log_data" {
  description = "deploy Lambda function to copy S3 from one bucket to another via SNS notifications"
  default     = false
}

variable "lambda_api_update" {
  description = "depoly Lambda function to update the api"
  default     = false
}

variable "lambda_file_format" {
  description = "deploy Lambda function to run the file format extraction"
  default     = false
}

variable "lambda_download_files" {
  description = "deploy Lambda function to download files to EFS"
  default     = false
}

variable "lambda_ecr_scan_notifications" {
  description = "deploy Lambda function to send notifications from ECR scans"
  default     = false
}

variable "lambda_ecr_scan" {
  description = "deploy Lambda function to run ECR image scans"
  default     = false
}

variable "lambda_export_authoriser" {
  description = "deploy Lambda function for the export api authoriser"
  default     = false
}

variable "lambda_service_unavailable" {
  description = "deploy Lambda function for the service unavailable page"
  default     = false
}

variable "lambda_signed_cookies" {
  description = "deploy Lambda function for the signed cookies API endpoint"
  default     = false
}

variable "lambda_export_status_update" {
  description = "deploy Lambda function for the export status update API endpoint"
  default     = false
}

variable "lambda_reporting" {
  description = "deploy Lambda function for the reporting"
  default     = false
}

variable "target_s3_bucket" {
  description = "Target S3 bucket ARN used for the Lambda log data function"
  default     = ""
}

variable "log_data_sns_topic" {
  description = "SNS topic ARN used for the Lambda log data function"
  default     = ""
}

variable "auth_url" {
  description = "The url of the keycloak server"
  default     = ""
}

variable "frontend_url" {
  description = "The url of the frontend"
  default     = ""
}

variable "upload_domain" {
  description = "The url of the upload url pointing to the cloudfront distribution which proxies s3 requests"
  default     = ""
}

variable "cloudfront_key_pair_id" {
  description = "The key pair used to sign the cookies for the cloudfront distribution which proxies s3 requests"
  default     = ""
}

variable "api_url" {
  description = "The url of the graphql api"
  default     = ""
}

variable "slack_bot_token" {
  description = "Slack bot token"
  default     = ""
}

variable "keycloak_reporting_client_id" {
  description = "Keycloak backend checks client id"
  default     = ""
}

variable "keycloak_reporting_client_secret" {
  description = "Keycloak backend checks client secret"
  default     = ""
}

variable "keycloak_backend_checks_client_secret" {
  description = "Keycloak backend checks client secret"
  default     = ""
}

variable "backend_checks_efs_access_point" {
  description = "The access point for the efs volume used by the backend checks"
  default     = ""
}

variable "backend_checks_efs_root_directory_path" {
  description = "The root directory of the efs volume used by the backend checks"
  default     = ""
}

variable "vpc_id" {
  description = "The VPC ID"
  default     = ""
}

variable "file_system_id" {
  default = ""
}

variable "s3_sns_topic" {
  default = ""
}

variable "use_efs" {
  default = false
}

variable "event_rule_arns" {
  type      = set(string)
  default   = []
  sensitive = true
}

variable "sns_topic_arns" {
  type    = set(string)
  default = []
}

variable "sqs_queue_arns" {
  type    = set(string)
  default = []
}

variable "notifications_topic" {
  default = ""
}

variable "periodic_ecr_image_scan_event_arn" {
  default = ""
}

variable "private_subnet_ids" {
  default = []
}

variable "api_gateway_arn" {
  default = ""
}

variable "backend_checks_api_arn" {
  default = ""
}

variable "backend_checks_client_secret" {
  default = ""
}

variable "user_admin_client_secret" {
  default = ""
}

variable "mount_target_zero" {
  default = ""
}

variable "mount_target_one" {
  default = ""
}

variable "consignment_database_sg_id" {
  default = ""
}

variable "lambda_create_db_users" {
  default = false
}

variable "db_admin_user" {
  default = ""
}

variable "db_admin_password" {
  default = ""
}

variable "db_url" {
  default = ""
}

variable "muted_scan_alerts" {
  description = "Parameter for the notification lambda listing which ECR scan alerts should be muted"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  default     = ""
  description = "The KMS arn to encrypt environment variables. Not all lambdas need this so it has a default"
}

variable "lambda_create_keycloak_db_users" {
  default = false
}

variable "keycloak_password" {
  default = ""
}

variable "efs_security_group_id" {
  default     = ""
  description = "The security group for the EFS mount targets"
}

variable "keycloak_database_security_group" {
  default = ""
}

variable "api_database_security_group" {
  default = ""
}

variable "lambda_name" {
  description = "The name of the lambda when using shared tf files like create_db_users"
  default     = ""
}

variable "database_name" {
  description = "The name to pass to the create db users lambda. Values are either consignmentapi to create the API users or bastion to create the bastion user"
  default     = ""
}

variable "reserved_concurrency" {
  description = "The total number of concurrent lambdas which can run at one time. Defaults to -1 which is unlimited up to the account limit"
  default     = -1
}

variable "lambda_create_keycloak_db_users_new" {
  default = false
}

variable "lambda_create_keycloak_user_api" {
  default = false
}

variable "lambda_create_keycloak_user_s3" {
  default = false
}

variable "s3_bucket_arn" {
  description = "The bucket which will trigger the lambda"
  default     = ""
}

variable "keycloak_user_management_api_arn" {
  default = ""
}

variable "judgment_export_s3_bucket_name" {
  default = ""
}

variable "standard_export_s3_bucket_name" {
  default = ""
}

variable "environment_full" {
  default = ""
}

variable "backend_checks_client_secret_path" {
  default = ""
}

variable "user_admin_client_secret_path" {
  default = ""
}

variable "reporting_client_secret_path" {
  default = ""
}

variable "lambda_rotate_keycloak_secrets" {
  default = false
}

variable "rotate_secrets_client_path" {
  default = ""
}

variable "rotate_keycloak_secrets_event_arn" {
  default = ""
}

variable "upload_bucket" {
  default = ""
}

variable "kms_export_bucket_key_arn" {
  description = "s3 export buckets KMS key arn"
  default     = ""
}

variable "da_event_bus_arn" {
  description = "Digital Archiving event bus arn"
  default     = ""
}

variable "da_event_bus_kms_key_arn" {
  description = "Digital Archiving event bus kms encryption arn"
  default     = ""
}

variable "user_session_timeout_mins" {
  description = "Timeout for a user session in minutes"
  default     = 60
}

variable "cloudwatch_log_retention_in_days" {
  description = "Number of days to retain logs. '0' equals indefinite retention"
  default     = 0
}
