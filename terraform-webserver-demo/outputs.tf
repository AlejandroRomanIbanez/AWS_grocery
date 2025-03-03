output "web_server_private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web_server.private_ip
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.grocery_db.endpoint
  sensitive   = true
}