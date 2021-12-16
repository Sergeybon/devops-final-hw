
# Public Zone
resource "aws_route53_zone" "primary" {
  name = "sbondsr05.ga"
}

# routing policy


resource "aws_route53_record" "primary" {
  allow_overwrite = true
  name            = "sbondsr05.ga"
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.primary.zone_id

  records = [
    aws_route53_zone.primary.name_servers[0],
    aws_route53_zone.primary.name_servers[1],
    aws_route53_zone.primary.name_servers[2],
    aws_route53_zone.primary.name_servers[3],
  ]
}


# Create Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "sbondsr05.ga"
  validation_method = "DNS"
}
# DNS
data "aws_route53_zone" "primary" {
  name         = "sbondsr05.ga"
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
  for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    record = dvo.resource_record_value
    type   = dvo.resource_record_type
  }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.primary : record.fqdn]
}
#fqdn
#resource "aws_lb_listener" "example" {
#  # ... other configuration ...
#
#  certificate_arn = aws_acm_certificate_validation.example.certificate_arn
#}

