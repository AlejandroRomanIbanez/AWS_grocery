variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
}

variable "ssh_cidr" {
  description = "Allowed CIDR block for SSH access"
  type        = list(string)
}

variable "http_cidr" {
  description = "Allowed CIDR block for HTTP/HTTPS access"
  type        = list(string)
}

variable "private_cidr" {
  description = "Allowed CIDR block for private RDS access"
  type        = list(string)
}

variable "manual_ip" {
  description = "Manual IP for SSH access, or 'auto' for dynamic IP detection"
  type        = string
}