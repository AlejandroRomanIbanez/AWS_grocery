# List of private subnet IDs where RDS will be deployed
variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS subnet group"
  type        = list(string)
}

# Master password for the RDS database
variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true  # This hides the value in Terraform output
}

# VPC ID where the RDS resources (security group, subnet group) are created
variable "vpc_id" {
  description = "ID of the VPC where the RDS instance will be deployed"
  type        = string
}

# Security Group ID of the EC2 instance, used to allow DB access from webserver
variable "ec2_sg_id" {
  description = "Security Group ID of the EC2 instance that can connect to the database"
  type        = string
}


