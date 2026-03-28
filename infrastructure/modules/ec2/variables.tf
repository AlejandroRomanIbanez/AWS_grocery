variable "ami_id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "ec2_sg_id" {
  type = string
}

variable "instance_profile_name" {
  type        = string
  description = "The IAM instance profile name from the storage module"
}

# --- Data for the Script ---

variable "db_endpoint" {
  type        = string
  description = "The RDS endpoint address"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "s3_bucket_id" {
  type        = string
  description = "The name/ID of the S3 bucket"
}

variable "container_name" {
  type    = string
  default = "grocerymate-backend"
}