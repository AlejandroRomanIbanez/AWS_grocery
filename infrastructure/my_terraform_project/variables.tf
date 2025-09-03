# Define the AMI ID for ec2 instances
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

# Define the database password for RDS
variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true # hiermit wird das Passwort nicht im Klartext in Terminal angezeigt
}

# Define public subnet for ec2 instance
variable "public_subnet_ids" {
  description = "List of the public subnet IDs for ALB and ASG"
  type        = list(string)
}
# Define vpc-id
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key to use for EC2 access"
  type        = string
}


variable "instance_type" {
  type = string                     # The type of the variable, in this case a string
  default = "t2.micro"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}


variable "key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}


variable "user_data_script" {
  description = "Path to user_data script"
  type        = string
}