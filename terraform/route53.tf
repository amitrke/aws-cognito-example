# Data source for the hosted zone
data "aws_route53_zone" "this" {
  name = var.domain_name
}

# Create a record for the subdomain to point to the Cloudfront distribution
resource "aws_route53_record" "webapp" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.webapp_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

# Create a record for the domain to point to the API Gateway

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
    evaluate_target_health = false
  }
}
