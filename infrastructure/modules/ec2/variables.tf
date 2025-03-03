variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}

variable "security_group" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "key_pair_name" {
  description = "SSH key pair name for EC2 instance"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role for EC2 instances"
  type        = string
  default     = "grocerymate-ec2-secrets-role"
}

variable "private_subnets" {
  description = "List of private subnet IDs for EC2 instances (optional)"
  type        = list(string)
  default     = []  # Makes it optional
}

variable "vpc_id" {
  description = "VPC ID for the instances"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "The ID of the Bastion security group"
}