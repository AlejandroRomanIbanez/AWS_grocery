# Output the DNS name of the Application Load Balancer
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

# Output the name of the target group
output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app_tg.arn
}

# Output the name of the Auto Scaling Group
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}
