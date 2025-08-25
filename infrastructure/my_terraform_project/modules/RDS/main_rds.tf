# Create a DB Subnet Group to define which private subnets RDS can use
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids  # List of private subnet IDs passed in

  tags = {
    Name = "rds-subnet-group"
  }
}

# Create a dedicated Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow PostgerSQL access from EC2 only"
  vpc_id      = var.vpc_id  # VPC where this SG will be created

  # Allow MySQL access (port 3306) from the EC2 instance's security group
  ingress {
    description      = "Allow PostgreSQL from EC2"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [var.ec2_sg_id]  # EC2 SG passed as input
  }

  # Allow all outbound traffic (default behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-grocerymate"
  }
}

# Create the actual RDS database instance
resource "aws_db_instance" "grocerymate_db" {
  allocated_storage      = 20                                # 20 GB of disk space
  engine                 = "postgres"                        # PostgreSQL as database engine
  engine_version         = "14.12"                         # RDS Version
  instance_class         = "db.t3.micro"                     # Free tier-eligible instance
  username               = "postgres"                    # Master username
  password               = var.db_password                   # Master password (from input variable)
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name  # Link to the subnet group
  vpc_security_group_ids = [aws_security_group.rds_sg.id]    # Attach the SG we created above
  skip_final_snapshot    = true                              # No final snapshot on delete
  publicly_accessible    = false                             # RDS should not be exposed to the internet

  tags = {
    Name = "grocerymate-rds"
  }
}
