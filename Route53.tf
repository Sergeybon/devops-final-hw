
#Create Certificate
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

