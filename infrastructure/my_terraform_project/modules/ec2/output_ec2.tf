# Output the EC2 instance's public IP address
output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

# Output the EC2 instance ID
output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.web_server.id
}

output "web_sg_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.web_server_sg.id
}
