# Outputs for ASG
output "launch_template_id" {
  value = aws_launch_template.grocery_app.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.grocery_app.latest_version
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_launch_template.grocery_app.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}