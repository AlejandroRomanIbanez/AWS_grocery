# The ID of the VPC where the ALB and ASG will be deployed
variable "vpc_id" {
  description = "The VPC ID to associate with ALB and Target Group"
  type        = string
}

# List of public subnet IDs for ALB and ASG placement
variable "public_subnet_ids" {
  description = "List of public subnet IDs to launch the ALB and EC2 instances"
  type        = list(string)
}

# Amazon Machine Image ID for EC2 instances in ASG
variable "ami_id" {
  description = "AMI ID used to launch EC2 instances"
  type        = string
}

# EC2 instance type (e.g., t2.micro)
variable "instance_type" {
  description = "Instance type for EC2 instances in ASG"
  type        = string
}

# Name of the SSH key pair to allow EC2 access
variable "key_name" {
  description = "Name of the SSH key to connect to EC2 instances"
  type        = string
}

# Shell script to run when the instance launches (for Docker installation)
variable "user_data_script" {
  description = "User data script to install Docker on EC2 instance"
  type        = string
}

# Security group ID that will be attached to EC2 instances launched by ASG
variable "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  type        = string
}
