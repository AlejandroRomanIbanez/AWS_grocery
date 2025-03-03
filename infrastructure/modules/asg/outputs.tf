# Output the ASG name for reference in other modules or root configuration
output "asg_name" {
  value = aws_autoscaling_group.grocery_asg.name
}