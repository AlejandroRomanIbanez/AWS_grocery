output "security_group_id" {
  description = "The ID of the Web Security Group"
  value       = aws_security_group.web_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}