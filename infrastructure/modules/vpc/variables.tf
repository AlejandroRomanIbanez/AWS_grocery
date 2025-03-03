# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public Subnet Configuration
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Private Subnet Configuration (Dynamic)
variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of available AZs"
  type        = list(string)
  default     = []
}