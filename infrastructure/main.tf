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

  # This is the magic link that injects the RDS address & container name
  user_data = templatefile("${path.module}/scripts/docker_setup.tftpl", {
    rds_address = aws_db_instance.grocerymate_db.address,
    container_name = "grocerymate_app",
    db_password  = var.db_password
  })

  # This ensures the DB is ready so we have an address to give to the script
  depends_on = [aws_db_instance.grocerymate_db]

  tags = {
    Name = "grocerymate-ec2"
  }
}

# Password protection
variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

# 4. RDS PostgreSQL Instance
resource "aws_db_instance" "grocerymate_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  db_name                = "grocerymate"
  username               = "postgres"
  password               = var.db_password
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
  force_destroy = true
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

# 7. This block disables the default "Block Public Access"  settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 8. This block grants "GetObject" (Read) permission to everyone (*)
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.avatars.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        # This "/*" is the magic fix
        Resource = [
             "${aws_s3_bucket.avatars.arn}/avatars/*"
        ]
      }
    ]
  })
  # This line is important! It ensures the "unlock" happens before the policy is applied
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# 9. Add default image to created S3 bucket:
resource "aws_s3_object" "default_avatar" {
bucket       = aws_s3_bucket.avatars.id
key          = "avatars/user_default.png"
source       = "${path.module}/../backend/avatar/user_default.png"
content_type = "image/png"
depends_on   = [aws_s3_bucket_policy.public_read_policy]
}

# 10. Enable Versioning (Keeps a history of the same filename)
resource "aws_s3_bucket_versioning" "avatar_versioning" {
bucket = aws_s3_bucket.avatars.id
versioning_configuration {
status = "Enabled"
}
}

# 11. The "Trash Collector" (Deletes everything but the current photo after 1 day)
resource "aws_s3_bucket_lifecycle_configuration" "avatar_lifecycle" {
  bucket = aws_s3_bucket.avatars.id

  rule {
    id     = "cleanup_old_versions"
    status = "Enabled"

    # This tells S3 to only look inside your "avatars" folder
    filter {
      prefix = "avatars/"
    }

    # This deletes 'non-current' (old) versions after 1 day
    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    # Optional: Cleans up failed uploads to save money
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}


# part of MVP
# 12. Create an SNS (Simple Notification Service) Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "grocerymate-threshold-alerts"
}

# 12.1 Subscribe your email to the Topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "gajananborade11@gmail.com"
}

# 13.The CPU Usage Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "GroceryMate-High-CPU-Usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"           # Must fail twice in a row to alert
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"         # Each period is 2 minutes (120 seconds)
  statistic           = "Average"
  threshold           = "80"          # The 80% mark
  alarm_description   = "This alarm monitors the GroceryMate EC2 CPU"

  dimensions = {
    InstanceId = aws_instance.web.id # Specifically watches our instance
  }

  # This "Publishes" the alert to your SNS topic
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# 14.The "Database Full" Alarm (RDS)

resource "aws_cloudwatch_metric_alarm" "rds_storage_alarm" {
  alarm_name          = "GroceryMate-RDS-Low-Storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1" # Because running out of disk space is a critical emergency.
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300" # 5 mins checking frequency
  statistic           = "Average" # calculates the Average amount of free space
  threshold           = "1000000000" # 1 GB in bytes
  alarm_description   = "Alert if RDS free space is less than 1GB"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.grocerymate_db.id # specifically watches the RDS instance
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# 15.1 Enable Request Metrics for the S3 Bucket
# Without this, the S3 Alarm will stay in "Insufficient Data" forever
resource "aws_s3_bucket_metric" "avatar_metrics" {
  bucket = aws_s3_bucket.avatars.id
  name   = "EntireBucket" # This matches the FilterId in your alarm
}

# 15.The "S3 Access Error" Alarm (S3)
# This helps us find out if users are getting 403 Forbidden errors when trying to see their photos
resource "aws_cloudwatch_metric_alarm" "s3_error_alarm" {
  alarm_name          = "GroceryMate-S3-4xx-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxErrors" # catches 403 Forbidden (permissions issues) and 404 Not Found (missing files).
  namespace           = "AWS/S3"
  period              = "3600" # Check hourly -> S3 errors can sometimes happen in tiny bursts due to internet hiccups.
  # Checking over an hour prevents "spam" alerts if one person has a bad connection for a second.
  statistic           = "Sum" #Unlike CPU where we want the Average, for errors we want the Total Count.
  # If 11 errors happen in that hour, the alarm fires.
  threshold           = "10"
  alarm_description   = "Alert if more than 10 S3 errors occur in an hour"

  dimensions = {
    BucketName = aws_s3_bucket.avatars.id
    FilterId   = "EntireBucket"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  # This tells Terraform to wait until the metrics are enabled before creating the alarm
  depends_on = [aws_s3_bucket_metric.avatar_metrics]
}

# 16.1 Special Provider for Billing (MUST be us-east-1)
# Even though your GroceryMate app, RDS, and S3 are in Frankfurt (eu-central-1),
# AWS stores all "Estimated Charges" metrics in a single global endpoint located in the us-east-1 region.
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# 16.2 A dedicated SNS Topic in Virginia for Billing
resource "aws_sns_topic" "billing_alerts_virginia" {
  provider = aws.virginia
  name     = "grocerymate-billing-alerts-virginia"
}

# 16.3 Subscribe your email to the Virginia Topic
resource "aws_sns_topic_subscription" "billing_email_virginia" {
  provider  = aws.virginia
  topic_arn = aws_sns_topic.billing_alerts_virginia.arn
  protocol  = "email"
  endpoint  = "gajananborade11@gmail.com"
}

# 16. The "Wallet Guard" ($30 Billing Alarm)
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider            = aws.virginia # <--- Tells Terraform to create this in Virginia
  alarm_name          = "GroceryMate-Monthly-Budget-Limit-30"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges" # It doesn't look at traffic or speed; it looks at the total dollar amount
  # you have accrued so far in the current month.
  # It is an "estimated" charge because taxes and final discounts aren't applied until the end of the month.
  namespace           = "AWS/Billing"
  period              = "21600"       # 6 hours
  statistic           = "Maximum" # For a CPU alarm, we use Average. But for money, we want the Maximum.
  threshold           = "30"          # Your $30 limit
  alarm_description   = "Alert when total monthly charges exceed $30"

  dimensions = {
    Currency = "USD"
  }

  # This still sends the alert to my SNS topic in Frankfurt!
  alarm_actions = [aws_sns_topic.billing_alerts_virginia.arn]
}

# Show IP of created EC2 instance automatically

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

# Adding an Elastic IP not paid by masterschool
# resource "aws_eip" "grocerymate_eip" {
#   instance = aws_instance.web.id
#   domain = "vpc"
#  }
#
# output "fixed_ip" {
#   value = aws_eip.grocerymate_eip.public_ip
# }

# The instant verification that S3 default image is publicly accessible
output "default_avatar_s3_url" {
description = "Click this link to verify the default avatar is public"
value       = "https://${aws_s3_bucket.avatars.bucket_regional_domain_name}/avatars/user_default.png"
}