variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase"  # You can change or remove default if you want manual input
}

variable "db_username" {
  description = "The database username"
  type        = string
  default     = "admin"  # Change to your preferred default or remove default
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "The EC2 key pair name"
  type        = string
  default     = "my-ec2-key"  # Change this to your actual key pair name in AWS
}


