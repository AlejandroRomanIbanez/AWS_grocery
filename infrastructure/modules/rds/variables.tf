variable "private_subnets" {
  description = "List of Private Subnet IDs for RDS"
  type        = list(string)
}

variable "security_group" {
  description = "Security Group ID for RDS"
  type        = string
}

variable "db_identifier" {
  description = "The identifier for the primary RDS database instance"
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