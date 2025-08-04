# Output the endpoint (host address) of the RDS database
output "rds_endpoint" {
  description = "The endpoint (hostname) of the RDS database"
  value       = aws_db_instance.grocerymate_db.endpoint
}

# Output the port used to connect to the RDS instance
output "rds_port" {
  description = "The port number used by the RDS database"
  value       = aws_db_instance.grocerymate_db.port # will return 5432
}

# Output the security group ID assigned to the RDS instance
output "rds_security_group_id" {
  description = "The ID of the security group used by the RDS instance"
  value       = aws_security_group.rds_sg.id
}
