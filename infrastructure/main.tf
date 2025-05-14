# mein provider und die Region Frankfurt auswählen
provider "aws" {
  region = "eu-central-1"
}

# SSH Key Pair generieren
#resource "aws_key_pair" "my_ssh_key" {
  #key_name   = "my_ssh_key"  # Der Name des Schlüssels
  #public_key = file("~/.ssh/id_rsa.pub")  # Pfad zum öffentlichen SSH-Schlüssel
#}

# ec2=aws_instance, ami ist mein Betrieb System und instance_type
resource "aws_instance" "my_terraform_server" {
  ami = "ami-0ecf75a98fe8519d7"  # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "terraform_key" # Verbindung zum ssh-key
  vpc_security_group_ids = [
  aws_security_group.ssh_access.id,
  aws_security_group.web_access.id
] # Verbindung zur Security Group mit SSH und WEB

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name #Verbindung mit IAM-Rolle

  tags = {
    Name = "MyFirstServerWithTerraform" # Beschreibung
  }
}
# Default-VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group für SSH-Zugriff
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "SSHFromAnywhereAllowed"
  vpc_id      = data.aws_vpc.default.id  # Default-VPC verwenden

  # Eingehende Regel (inbound): SSH auf Port 22
  ingress {
    description = "SSHFromAnywhereAllow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # hier muss ich spaeter meine IP eingeben
  }

  # Ausgehende Regel (outbound): Alles erlaubt
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 bedeutet: alle Protokolle
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group für RDS (PostgreSQL Port 5432)
resource "aws_security_group" "rds_sg" {
  name        = "rds_postgres_sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_access.id]  # erlaubt Zugriff von EC2 SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# RDS PostgreSQL-Instance
resource "aws_db_instance" "my_postgres" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15.12"
  instance_class         = "db.t3.micro"
  db_name                = "my_database"
  username               = "postgres"
  password               = "postgres1234"  # In Produktion: Variable/Secret Manager
  parameter_group_name   = "default.postgres15"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "MyPostgresRDS"
  }
}

resource "aws_security_group" "web_access" {
  name        = "web_access_sg"
  description = "Allow web access"
  vpc_id      = data.aws_vpc.default.id

  # Erlaube HTTP-Zugriff auf Port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Erlaube Zugriff auf Port 5001
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ausgehender Verkehr erlauben (Standard)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
