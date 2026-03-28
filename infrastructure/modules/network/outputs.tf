output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.grocerymate_vpc.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet for the EC2"
  value       = aws_subnet.public_1.id
}

output "private_subnets" {
  description = "The IDs of the private subnets for the RDS"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}