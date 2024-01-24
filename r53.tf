# --------------------------------------------------------------------------------------------------
# Route 53 entry for the ALB
# --------------------------------------------------------------------------------------------------
resource "aws_route53_record" "alb" {
  # Endpoint DNS record
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.jenkins.dns_name
    zone_id                = aws_lb.jenkins.zone_id
    evaluate_target_health = true
  }
}