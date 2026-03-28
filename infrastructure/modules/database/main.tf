# 1. Subnet Group (Tells RDS which private subnets to use)
resource "aws_db_subnet_group" "grocerymate_db_subnet_group" {
  name       = "grocerymate-db-subnet-group"
  subnet_ids = var.subnet_ids # <--- Coming from Network Module

  tags = { Name = "grocerymate-db-subnet-group" }
}

# 2. The RDS Instance
resource "aws_db_instance" "grocerymate_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  db_name                = "grocerymate"
  username               = "postgres"
  password               = var.db_password # <--- Sensitive variable
  db_subnet_group_name   = aws_db_subnet_group.grocerymate_db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id] # <--- Coming from Security Module
  skip_final_snapshot    = true
  publicly_accessible    = false # <--- Keep it private!

  identifier = "grocerymate-db-dev" # Try a slightly fresh name
  tags = {
    Name        = "grocerymate-db"
    Environment = "Dev"
  }
}