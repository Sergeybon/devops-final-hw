
# creates the Route 53 hosted zone aws_route53_zone
resource "aws_route53_zone" "main" {
  name = "sbondar05.ga"
}

# requests the certificate from Certificate Manager aws_acm_certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "sbondar05.ga"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# creates the CNAME record Certificate Manager uses to validate you own the domain aws_route53_record
resource "aws_route53_zone" "example" {
  name = "test.sbondar05.ga"
}

resource "aws_route53_record" "example-ns" {
  allow_overwrite = true
  name            = "test.sbondar05.ga"
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.example.zone_id

  records = [
    aws_route53_zone.example.name_servers[0],
    aws_route53_zone.example.name_servers[1],
    aws_route53_zone.example.name_servers[2],
    aws_route53_zone.example.name_servers[3],
  ]
}

# waits for the certificate to be issued  aws_acm_certificate_validation
resource "aws_acm_certificate" "example" {
  domain_name               = "sbondar05.ga"
  subject_alternative_names = ["www.sbondar05.ga", "sbondar05.ga"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}



