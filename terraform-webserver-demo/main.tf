provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

# 🔹 Security Group for Web Server & Database
resource "aws_security_group" "web_sg" {
  name        = var.security_group_name
  description = "Allow HTTP, SSH, and DB access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_cidr
  }

  # Allow EC2 to communicate with RDS on port 5432
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔹 EC2 Instance (Web Server)
resource "aws_instance" "web_server" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_pair_name
  security_groups      = [aws_security_group.web_sg.name]
  associate_public_ip_address = false  # EC2 is in a private subnet

  tags = {
    Name = var.instance_name
  }

  # Install Apache & Allow Web Access
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello, World!" > /var/www/html/index.html
              EOF
}

# 🔹 RDS PostgreSQL Database
resource "aws_db_instance" "grocery_db" {
  allocated_storage    = 20
  engine              = "postgres"
  engine_version      = "13.3"
  instance_class      = "db.t3.micro"
  username           = var.db_username
  password           = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  publicly_accessible  = false
  skip_final_snapshot  = true

  tags = {
    Name = "GroceryMate-DB"
  }
}

# 🔹 Subnet Group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "grocery-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "GroceryMate RDS Subnet Group"
  }
}