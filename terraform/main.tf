# Infrastructure for GroceryMate
# Created by: Youssef El Maach
# Tools: Terraform, AWS (EC2, RDS, S3, Lambda, SNS)

# ==========================================================
# TERRAFORM KONFIGURATION
# ==========================================================

provider "aws" {
  region = "eu-central-1" # Frankfurt
}

# --- AUTOMATISCHE SUCHE NACH DEM BETRIEBSSYSTEM ---
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# --- DATENQUELLE FÜR DAS VPC (AKTIV) ---
data "aws_vpc" "default" {
  default = true
}

# --- DATENQUELLE FÜR ROUTENTABELLE (AUSKOMMENTIERT WEGEN SCP) ---
/*
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}
*/

# --- SECURITY GROUP (Firewall) ---
resource "aws_security_group" "grocery_sg" {
  name        = "grocery-app-firewall"
  description = "Security Group for EC2 and RDS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
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

# --- EC2 INSTANCE (Server) ---
resource "aws_instance" "grocery_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.grocery_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.grocery_ec2_profile.name
  key_name               = "startkey"

  tags = {
    Name = "Grocery-Web-Server"
  }
}

# --- RDS INSTANCE (Datenbank) ---
resource "aws_db_instance" "grocery_db" {
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  db_name             = "grocerymate_db"
  username            = "grocery_user"
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible = true
}

# --- VPC ENDPOINT (AUSKOMMENTIERT WEGEN RECHTEN) ---
/*
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = data.aws_vpc.default.id
  service_name = "com.amazonaws.eu-central-1.s3"
  route_table_ids = [data.aws_route_table.default.id]

  tags = {
    Name = "grocery-s3-gateway-endpoint"
  }
}
*/

# --- AUSGABEWERTE ---
output "server_public_ip" {
  value = aws_instance.grocery_server.public_ip
}

output "database_endpoint" {
  value = aws_db_instance.grocery_db.endpoint
}