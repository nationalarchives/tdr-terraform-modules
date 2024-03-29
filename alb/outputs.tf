output "alb_dns_name" {
  value = aws_alb.alb_module.dns_name
}

output "alb_zone_id" {
  value = aws_alb.alb_module.zone_id
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.alb_module.arn
}

output "alb_target_group_id" {
  value = aws_alb_target_group.alb_module.id
}

output "alb_arn" {
  value = aws_alb.alb_module.arn
}

output "alb_id" {
  value = aws_alb.alb_module.id
}

