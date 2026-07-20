resource "aws_route53_zone" "api" {
  name = var.domain_name
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options :
    dvo.domain_name => dvo
  }

  zone_id = aws_route53_zone.api.zone_id
  type    = each.value.resource_record_type
  name    = each.value.resource_record_name
  records = [each.value.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.api.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.aws_lb.api.dns_name
    zone_id                = data.aws_lb.api.zone_id
    evaluate_target_health = true
  }
}