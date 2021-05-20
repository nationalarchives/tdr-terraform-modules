resource "aws_flow_log" "flowlog" {
  iam_role_arn    = var.role_arn
  log_destination = var.log_group_arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}

resource "aws_flow_log" "jenkins_flowlog_s3" {
  log_destination_type = "s3"
  log_destination      = var.s3_arn
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
}