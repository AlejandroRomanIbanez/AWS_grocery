resource "aws_security_group" "web_sg" {
  name        = var.security_group_name
  description = "Allow inbound HTTP, HTTPS, SSH, and DB traffic"
  vpc_id      = var.vpc_id  # ✅ Ensures the security group is tied to the correct VPC

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_cidr  # ✅ More flexible for controlled access
  }

  # Allow HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.http_cidr  # ✅ Keeps control over HTTPS access
  }

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr  # ✅ Uses a variable for restricted SSH access, now IPv4
  }

  # Allow EC2 to communicate with RDS on port 5432
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_cidr  # ✅ Uses private subnet CIDR instead of referencing itself
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Security Group"  # ✅ Helps track security groups in AWS
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for the Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.manual_ip == "auto" ? [format("%s/32", data.external.my_ip.result.ip)] : [var.manual_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionHostSG"
  }
}

data "external" "my_ip" {
  program = ["bash", "-c", "echo '{\"ip\": \"'$(curl -s https://checkip.amazonaws.com)'\"}'"]
}