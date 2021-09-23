output "antivirus_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_av.*.id
}

output "download_files_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_download_files.*.id
}

output "file_format_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_file_format.*.id
}

output "checksum_lambda_sg_id" {
  value = aws_security_group.allow_efs_lambda_checksum.*.id
}

output "ecr_scan_notification_lambda_arn" {
  value = aws_lambda_function.notifications_lambda_function.*.arn
}

output "ecr_scan_lambda_arn" {
  value = aws_lambda_function.ecr_scan_lambda_function.*.arn
}

output "export_api_authoriser_arn" {
  value = local.export_api_authoriser_arn
}

output "sign_cookies_arn" {
  value = local.sign_cookies_arn
}

output "create_users_lambda_security_group_id" {
  value = aws_security_group.create_db_users_lambda.*.id
}

output "create_keycloak_user_lambda_security_group" {
  value = aws_security_group.create_keycloak_db_user_lambda.*.id
}

output "antivirus_lambda_role" {
  value = aws_iam_role.lambda_iam_role.*.arn
}

output "download_files_lambda_role" {
  value = aws_iam_role.download_files_lambda_iam_role.*.arn
}

output "file_format_lambda_role" {
  value = aws_iam_role.file_format_lambda_iam_role.*.arn
}

output "checksum_lambda_role" {
  value = aws_iam_role.checksum_lambda_iam_role.*.arn
}
