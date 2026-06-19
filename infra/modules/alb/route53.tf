resource "aws_route53_zone" "api" {
  name = var.domin_name
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for vdo in aws_acm_certificate.api.domain_validation_options :
    dvo.domain_name => dvo
  }

  zone_id = aws_route53_zone.api.zone_id
  type    = each.value.resource_record_type
  name    = each.value.resource_record_name
  records = [each.value.resource_record_value]
  ttl     = 60
}