resource "aws_vpc_endpoint" "endpoint" {
  vpc_id       = var.vpc_id
  service_name = var.service_name

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.service_name}-endpoint" }
    )
  )
}