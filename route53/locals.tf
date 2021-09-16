locals {
  hosted_zone_id           = var.create_hosted_zone == true ? aws_route53_zone.hosted_zone[0].id : var.hosted_zone_id
  hosted_zone_name_servers = var.create_hosted_zone == true ? aws_route53_zone.hosted_zone[0].name_servers : var.hosted_zone_name_servers
}