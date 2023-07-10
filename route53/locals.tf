locals {
  hosted_zone_id           = var.create_hosted_zone == true ? aws_route53_zone.hosted_zone[0].id : data.aws_route53_zone.hosted_zone[0].id
  hosted_zone_name_servers = var.create_hosted_zone == true ? aws_route53_zone.hosted_zone[0].name_servers : data.aws_route53_zone.hosted_zone[0].name_servers
}
