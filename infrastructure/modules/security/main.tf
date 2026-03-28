# 2. Updated Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "grocerymate-ec2-sg"
  description = "Allow SSH and App traffic"
  vpc_id      = var.vpc_id # <--- IMPORTANT: Link to the new VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # <--- FIX: Using variable instead of 0.0.0.0/0
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Still public so users can see the app
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Updated Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "grocerymate-rds-sg"
  description = "Allow traffic from EC2 only"
  vpc_id      = var.vpc_id # <--- IMPORTANT: Link to the new VPC

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}