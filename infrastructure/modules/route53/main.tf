# Retrieve the existing Route 53 hosted zone for your domain
data "aws_route53_zone" "my_tennis_trainer_zone" {
  name         = "my-tennistrainer-24.de"  # Updated to your new domain
  private_zone = false                      # Use a public hosted zone (not private)
}

# Create an A record that aliases to the ALB
resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.my_tennis_trainer_zone.zone_id  # Reference the hosted zone ID
  name    = "my-tennistrainer-24.de"           # Fully qualified domain name
  type    = "A"                                 # A record type for aliasing to ALB

  alias {
    name                   = var.alb_dns_name  # ALB DNS name from the alb module
    zone_id                = var.alb_zone_id   # ALB zone ID from the alb module
    evaluate_target_health = true              # Use ALB health checks
  }
}

# Variable for ALB DNS name
variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

# Variable for ALB zone ID
variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}