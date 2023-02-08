resource "aws_route53_zone" "hosted_zone" {
  count = var.create_hosted_zone == true ? 1 : 0
  name  = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.project}-${var.environment_full_name}" }
    )
  )
}

resource "aws_route53_record" "dns" {
  count   = var.a_record_name == "" ? 0 : 1
  zone_id = local.hosted_zone_id
  name    = var.a_record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = false
  }
}

# conditional includes the block below for environments with a manually created hosted zone imported to the Terraform state file
resource "aws_route53_record" "hosted_zone_ns" {
  count   = var.manual_creation == true ? 1 : 0
  zone_id = local.hosted_zone_id
  name    = var.environment_full_name == "production" ? "${var.project}.${var.domain}" : "${var.project}-${var.environment_full_name}.${var.domain}"
  type    = "NS"
  ttl     = var.ns_ttl

  records = [
    "${local.hosted_zone_name_servers.0}.",
    "${local.hosted_zone_name_servers.1}.",
    "${local.hosted_zone_name_servers.2}.",
    "${local.hosted_zone_name_servers.3}.",
  ]
}

resource "aws_route53_key_signing_key" "signing_key" {
  count                      = local.dnssec_count
  hosted_zone_id             = aws_route53_zone.hosted_zone[count.index].id
  key_management_service_arn = var.kms_key_arn
  name                       = "${var.project}-signing-key-${var.environment_full_name}"
}

resource "aws_route53_hosted_zone_dnssec" "dns_sec" {
  count = local.dnssec_count
  depends_on = [
    aws_route53_key_signing_key.signing_key
  ]
  hosted_zone_id = aws_route53_key_signing_key.signing_key[count.index].hosted_zone_id
}

resource "aws_route53_resolver_dnssec_config" "dnssec_config" {
  count = local.dnssec_count
  resource_id = var.vpc_id
}
