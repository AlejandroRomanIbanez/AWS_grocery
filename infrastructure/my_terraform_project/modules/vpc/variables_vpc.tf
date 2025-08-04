# Define the VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Define the CIDR block for public subnet 1
variable "public_subnet_cidr_1" {
  description = "CIDR block for public subnet 1"
  type        = string
}

# Define the CIDR block for public subnet 2
variable "public_subnet_cidr_2" {
  description = "CIDR block for public subnet 2"
  type        = string
}

# Availability zones for each public subnet
variable "availability_zone_1" {
  description = "Availability zone for public subnet 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability zone for public subnet 2"
  type        = string
}