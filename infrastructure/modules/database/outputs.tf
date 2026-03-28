output "db_endpoint" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.grocerymate_db.address
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.grocerymate_db.id
}

output "rds_port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.grocerymate_db.port
}