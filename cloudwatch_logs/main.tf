resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = var.name
  tags = merge(
    var.common_tags,
    map(
      "Name", var.name,
    )
  )
}
