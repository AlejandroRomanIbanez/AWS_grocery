variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

variable "profile" {
  description = "AWS CLI Profile"
  type        = string
  default     = "AdministratorAccess-577638354511"
}

variable "ami" {
  description = "Amazon Machine Image (AMI) for EC2"
  type        = string
  default     = "ami-099d3ad9594677fa"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the existing AWS Key Pair"
  type        = string
  default     = "grocery"
}

variable "instance_name" {
  description = "EC2 Instance Name"
  type        = string
  default     = "GroceryMate-Web"
}

variable "security_group_name" {
  description = "Security group name"
  type        = string
  default     = "web_sg"
}

variable "ssh_cidr" {
  description = "Allowed SSH IP range"
  type        = list(string)
  default     = ["193.177.209.209/32"]
}

variable "http_cidr" {
  description = "Allowed HTTP IP range"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "private_subnets" {
  description = "List of private subnets for RDS"
  type        = list(string)
}