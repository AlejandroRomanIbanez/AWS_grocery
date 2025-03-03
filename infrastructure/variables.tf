# AWS Region
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

# AWS Profile (For AWS CLI authentication)
variable "profile" {
  description = "AWS CLI Profile for authentication"
  type        = string
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# EC2 Instance Name
variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "grocerymate-key"
}

# 🔹 AWS Secrets Manager (For Secure Database Credentials)
variable "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret storing DB credentials"
  type        = string
}

# IP for SSH Access
variable "manual_ip" {
  description = "Manually set public IP address for SSH access (set to 'auto' for dynamic IP or an IPv4 CIDR like '109.193.23.119/32')"
  type        = string
  default     = "auto"  # Default to dynamically fetch IP via data.external.my_ip

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.manual_ip)) || var.manual_ip == "auto"
    error_message = "The manual_ip must be a valid IPv4 address (e.g., 109.193.23.119) or set to 'auto'."
  }
}

variable "security_group" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

# Variable for private subnet IDs
variable "subnet_ids" {
  description = "List of private subnet IDs for ASG instances"
  type        = list(string)
}

# Variable for launch template ID
variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

# Variable for launch template version
variable "launch_template_version" {
  description = "Version of the launch template"
  type        = string
}

# Variable for ALB target group ARN
variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "db_identifier" {
  description = "The unique identifier for the primary RDS instance"
  type        = string
}

variable "db_arn" {
  description = "The ARN of the primary RDS database instance"
  type        = string
}

variable "db_credentials_secret_name" {
  description = "The name of the Secrets Manager secret storing RDS credentials"
  type        = string
}

# EC2 Configuration
variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}