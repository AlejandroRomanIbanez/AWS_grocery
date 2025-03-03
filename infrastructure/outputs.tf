# Existing outputs (if any, from your previous main.tf)
output "rds_endpoint" {
  description = "Endpoint of the primary RDS instance"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = module.rds.rds_port
}

output "db_credentials_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret storing DB credentials"
  value       = module.rds.db_credentials_secret_arn
}

output "replica_endpoint" {
  description = "Endpoint of the RDS read replica"
  value       = module.rds.replica_endpoint
}

output "validated_ip" {
  description = "The final validated IP used in Terraform."
  value       = var.manual_ip == "auto" ? data.external.my_ip[0].result.ip : var.manual_ip
}