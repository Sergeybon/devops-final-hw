
# creates the Route 53 hosted zone aws_route53_zone
resource "aws_route53_zone" "main" {
  name = "sbondar05.ga"
}

# requests the certificate from Certificate Manager aws_acm_certificate
resource "aws_acm_certificate" "this" {
  domain_name       = "sbondar05.ga"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this-CNAME" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "sbondar05.ga"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

#resource "aws_route53_record" "this-cname" {
#  zone_id = aws_route53_zone.main.zone_id
#  name    = ""
#  type    = "A"
#  ttl     = "300"
#  records = [aws_lb.this.dns_name]
#}
 #creates the record Certificate Manager uses to validate you own the domain aws_route53_record
#resource "aws_route53_zone" "sbondar05" {
#  name = "test.sbondar05.ga"
#}

#resource "aws_route53_record" "this-ns" {
#  allow_overwrite = true
#  name            = "test.sbondar05.ga"
#  ttl             = 172800
#  type            = "NS"
#  zone_id         = aws_route53_zone.main.zone_id
#
#  records = [
#    aws_route53_zone.main.name_servers[0],
#    aws_route53_zone.main.name_servers[1],
#    aws_route53_zone.main.name_servers[2],
#    aws_route53_zone.main.name_servers[3],
#  ]
#}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.main.id


    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
  depends_on = [aws_route53_record.this]
}



