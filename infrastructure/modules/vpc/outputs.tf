# Output VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public[0].id
}

# Output list of private subnet IDs
output "private_subnets" {
  value = aws_subnet.private[*].id
}

# Output list of public subnet IDs
output "public_subnets" {
  value = aws_subnet.public[*].id
}

# Output ALB security group ID
output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}