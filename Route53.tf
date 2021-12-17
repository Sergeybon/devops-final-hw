
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


# waits for the certificate to be issued  aws_acm_certificate_validation