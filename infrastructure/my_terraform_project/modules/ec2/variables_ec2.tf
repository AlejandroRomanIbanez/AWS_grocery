# AMI ID used to launch the EC2 instance (Amazon Linux 2)
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

# EC2 instance type (t2.micro)
variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
}

# Path to your SSH public key (e.g., ~/.ssh/id_rsa.pub)
variable "public_key_path" {
  description = "Path to the SSH public key to use for EC2 access"
  type        = string
}

# SSH key pair name for accessing the EC2 instance
variable "key_name" {
  description = "Name of the SSH key pair to connect to the EC2 instance"
  type        = string
}

# VPC ID where the EC2 instance will be launched
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# Public subnet ID where the EC2 instance will be launched
variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type        = string
}

# Shell script used as user_data to install Docker on instance launch
variable "user_data_script" {
  description = "User data script to install and configure Docker for EC2 instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to attach to the EC2 instance"
  type        = string
}
