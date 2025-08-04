# Output the VPC ID to use it in the root module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_grocery.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}


# Output both public subnet IDs as a list
output "public_subnet1_id" {
  description = "ID of public subnet 1"
  value       = aws_subnet.public1.id
}

output "public_subnet2_id" {
  description = "ID of public subnet 2"
  value       = aws_subnet.public2.id
}


# Output for Private Subnet 1 for RDS
output "private_subnet_1_id" {
  description = "ID of the first private subnet"
  value       = aws_subnet.private1.id
}

# Output for Private Subnet 2 for RDS
output "private_subnet_2_id" {
  description = "ID of the second private subnet"
  value       = aws_subnet.private2.id
}

# Output for both private subnets as a list (for RDS or ASG)
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

