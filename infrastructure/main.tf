# 0 - Remote Backend Configuration
# This stores the state file in S3 instead of locally on my Mac
terraform {
  backend "s3" {
    bucket = "grocerymate-tf-state-gajanan-x12"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"
  }
}

# 1. Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "grocerymate-ec2-sg"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "grocerymate-rds-sg"
  description = "Allow traffic from EC2 only"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

# 3. EC2 Instance (Frankfurt Region)
resource "aws_instance" "web" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # This is the "Link"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Enable SSH access using the .pem file
  key_name = "masterschool-key"

  # This is the magic link that injects the RDS address
  user_data = templatefile("${path.module}/scripts/docker_setup.tftpl", {
    rds_address = aws_db_instance.grocerymate_db.address
  })

  # This ensures the DB is ready so we have an address to give to the script
  depends_on = [aws_db_instance.grocerymate_db]

  tags = {
    Name = "grocerymate-ec2"
  }
}

# 4. RDS PostgreSQL Instance
resource "aws_db_instance" "grocerymate_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  db_name                = "grocerymate"
  username               = "postgres"
  password               = "grocerymate123"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "grocerymate-db"
  }
}

# 5. S3 Bucket for User Avatars
resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatars-gajanan"
  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}

# 6. IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "grocery-ec2-role-gajanan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach S3 Full Access Policy to the Role
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create the Instance Profile (The "Badge" for EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocery_ec2_profile_gajanan"
  role = aws_iam_role.ec2_s3_access_role.name
}


# Show IP of created EC2 instance automatically

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}
