output "ec2_role_name" {
  description = "The IAM role assigned to EC2 for Secrets Manager access"
  value       = aws_iam_role.ec2_secrets_manager_role.name
}