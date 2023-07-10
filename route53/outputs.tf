output "hosted_zone_id" {
  value = var.create_hosted_zone == true ? aws_route53_zone.hosted_zone[0].zone_id : data.aws_route53_zone.hosted_zone[0].zone_id
}
