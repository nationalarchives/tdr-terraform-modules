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

resource "aws_vpc_endpoint_policy" "endpoint" {
  count           = var.policy == null ? 0 : 1
  vpc_endpoint_id = aws_vpc_endpoint.endpoint.id
  policy          = var.policy
}
