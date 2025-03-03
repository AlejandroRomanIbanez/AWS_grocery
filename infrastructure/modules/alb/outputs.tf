output "alb_dns_name" {
  value = aws_lb.grocerymate_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.grocerymate_tg.arn
}

output "alb_zone_id" {
  value = aws_lb.grocerymate_alb.zone_id  # Add this to provide the ALB's hosted zone ID
}

output "alb_name" {
  description = "Name of the ALB"
  value       = aws_lb.grocerymate_alb.name
}