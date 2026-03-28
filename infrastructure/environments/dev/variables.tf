# Define the Variables

# 1. My IP for SSH Security
variable "my_ip" {
  description = "My workstation IP for SSH access (e.g., 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/0" # Change this to your actual IP later!
}

# 2. RDS Password (Moved from main.tf)
variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

# 3. email address (Moved from main.tf)
variable "alert_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = "gajananborade11@gmail.com"
}

# --- App Settings ---
# 4. Bucket name (Moved from main.tf)
variable "avatar_bucket_name" {
  default = "grocerymate-avatars-gajanan"
}

# 5. container name (Moved from main.tf)
variable "container_name" {
  default = "grocerymate_app"
}

# --- Infrastructure ---
variable "aws_region" {
  default = "eu-central-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI for Frankfurt"
  default     = "ami-04e601abe3e1a910f"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "key_name" {
  description = "The SSH key pair name created in AWS Console"
  type        = string
  default     = "masterschool-key"
}