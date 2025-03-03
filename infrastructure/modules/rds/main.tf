# ✅ Generate a secure random password dynamically
resource "random_password" "db_password" {
  length  = 16   # Password length (16 characters)
  special = true # Include special characters (!@#$%^&)
}

# ✅ Store Database Credentials Securely in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "grocerymate-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "grocerymate_admin"  # ✅ Static username
    password = random_password.db_password.result  # ✅ Uses dynamically generated password
  })
}

# ✅ RDS Instance - Uses Credentials from Secrets Manager
resource "aws_db_instance" "grocery_db" {
  identifier            = var.db_identifier
  allocated_storage     = 20
  storage_type          = "gp2"
  engine               = "postgres"
  engine_version       = "15.12"  # ✅ LTS-stable version
  instance_class       = "db.t3.micro"
  db_name              = "grocerymate"

  # ✅ Dynamically Fetch Credentials from AWS Secrets Manager
  username = jsondecode(aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]

  db_subnet_group_name  = aws_db_subnet_group.grocery_db_subnet.name
  vpc_security_group_ids = [var.security_group]

  publicly_accessible   = false  # ✅ More secure (no public access)
  skip_final_snapshot   = true   # ✅ Avoid snapshot costs (change in production)

  # ✅ Enable automated backups (Fix for replica creation)
  backup_retention_period = 7
  backup_window           = "02:00-03:00"  # ✅ Correct format: hh24:mi-hh24:mi

  # ✅ Fix 2: Correct maintenance window format (WITH day prefix)
  maintenance_window      = "sun:04:00-sun:05:00"  # ✅ Correct format: ddd:hh24:mi-ddd:hh24:mi

  # ✅ Ensure RDS waits for Secrets Manager to complete first
  depends_on = [aws_secretsmanager_secret_version.db_credentials_version]

  tags = {
    Name      = "GroceryMate-DB-Primary"
    DBVersion = "15.12"
  }
}

# ✅ RDS Read Replica
resource "aws_db_instance" "grocery_db_replica" {
  identifier              = "grocerymate-replica"
  replicate_source_db     = var.db_arn  # ✅ Corrected reference
  instance_class          = "db.t3.micro"  # Match primary instance class
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15.12"        # ✅ Ensure replica matches the primary DB version
  db_subnet_group_name    = aws_db_subnet_group.grocery_db_subnet.name
  vpc_security_group_ids  = [var.security_group]
  publicly_accessible     = false
  skip_final_snapshot     = true

  # ✅ Enable backups for the replica (optional but recommended)
  backup_retention_period = 7
  backup_window           = "02:00-03:00"  # ✅ Different backup window than primary

  # ✅ Maintenance window different from the primary to prevent simultaneous downtime
  maintenance_window      = "mon:04:00-mon:05:00"

  tags = {
    Name      = "GroceryMate-DB-Replica"
    DBVersion = "15.12"
  }

  depends_on = [aws_db_instance.grocery_db]  # ✅ Ensure replica waits for primary DB
}

# ✅ RDS Subnet Group - Uses Private Subnets
resource "aws_db_subnet_group" "grocery_db_subnet" {
  name       = "grocery-db-subnet-group"
  subnet_ids = var.private_subnets  # ✅ Uses private subnets dynamically

  tags = {
    Name = "GroceryMate RDS Subnet Group"
  }
}