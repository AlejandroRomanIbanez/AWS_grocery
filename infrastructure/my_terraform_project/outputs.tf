# Output the DNS name of the ALB
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb_asg.alb_dns_name
}

# Output the Lambda function name
output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = module.lambda.lambda_function_name
}

# Output the name of the S3 bucket
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.s3_bucket_name
}

# Output the EC2 instance security group ID
output "ec2_security_group_id" {
  description = "Security group ID of the EC2 instance"
  value       = module.webserver.web_sg_id
}

# Output the RDS endpoint (optional, only if you use RDS)
output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value       = module.rds.rds_endpoint
}
