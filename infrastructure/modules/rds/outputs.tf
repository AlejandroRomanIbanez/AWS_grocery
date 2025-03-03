output "rds_endpoint" {
  description = "The endpoint of the primary RDS instance"
  value       = aws_db_instance.grocery_db.endpoint
  sensitive   = true  # Keeps endpoint secure
}

output "rds_port" {
  description = "Port of the RDS instance for database connection"
  value       = aws_db_instance.grocery_db.port
}

# ✅ Output the Secrets Manager ARN (Useful for Debugging & IAM Policies)
output "db_credentials_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret storing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "replica_endpoint" {
  description = "Endpoint of the RDS read replica"
  value       = aws_db_instance.grocery_db_replica.endpoint
}

output "rds_identifier" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.grocery_db.identifier
}