# Output the name of the IAM role
output "ec2_role_name" {
  description = "The name of the IAM role for EC2"
  value       = aws_iam_role.ec2_role.name
}

# Output the name of the instance profile
output "ec2_instance_profile_name" {
  description = "The name of the IAM instance profile for EC2"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}
