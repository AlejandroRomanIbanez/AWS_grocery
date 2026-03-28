# This grabs your current public IP automatically
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

# This automatically finds the latest Ubuntu 24.04 ID in your region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 1. Network Module
module "network" {
  source = "../../modules/network"
}

# 2. Storage Module
module "storage" {
  source             = "../../modules/storage"
  avatar_bucket_name = var.avatar_bucket_name
}

# 3. Security Module
module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
  # This uses the dynamic IP from the data source above
  # chomp() removes any hidden tiny spaces/newlines from the IP string
  my_ip  = "${chomp(data.http.my_ip.response_body)}/32"
}

# 4. Database Module
module "database" {
  source      = "../../modules/database"
  subnet_ids  = module.network.private_subnets
  rds_sg_id   = module.security.rds_sg_id
  db_password = var.db_password
}

# 5. EC2 Module
module "ec2" {
  source           = "../../modules/ec2"
  ami_id           = data.aws_ami.ubuntu.id
  instance_type    = "t3.micro"
  key_name         = var.key_name
  public_subnet_id = module.network.public_subnet_id
  ec2_sg_id        = module.security.ec2_sg_id
  db_endpoint      = module.database.db_endpoint
  db_password      = var.db_password
  s3_bucket_id     = module.storage.bucket_id
  container_name   = "grocerymate-backend"
  instance_profile_name = module.storage.ec2_profile_name

}

# --- CloudWatch Alarms ---

resource "aws_sns_topic" "alerts" {
  name = "grocerymate-threshold-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# 15. The CPU Usage Alarm (Fixed Reference)
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "GroceryMate-High-CPU-Usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm monitors the GroceryMate EC2 CPU"

  dimensions = {
    InstanceId = module.ec2.instance_id # FIXED: Points to module output
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# 16. The "Database Full" Alarm (Fixed Reference)
resource "aws_cloudwatch_metric_alarm" "rds_storage_alarm" {
  alarm_name          = "GroceryMate-RDS-Low-Storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000000"
  alarm_description   = "Alert if RDS free space is less than 1GB"

  dimensions = {
    DBInstanceIdentifier = module.database.db_instance_id # FIXED: Points to module output
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# 17. Enable Request Metrics (Fixed Reference)
resource "aws_s3_bucket_metric" "avatar_metrics" {
  bucket = module.storage.bucket_id # FIXED: Points to module output
  name   = "EntireBucket"
}

# 18. The "S3 Access Error" Alarm (Fixed Reference)
resource "aws_cloudwatch_metric_alarm" "s3_error_alarm" {
  alarm_name          = "GroceryMate-S3-4xx-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = "3600"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert if more than 10 S3 errors occur in an hour"

  dimensions = {
    BucketName = module.storage.bucket_id # FIXED: Points to module output
    FilterId   = "EntireBucket"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  depends_on    = [aws_s3_bucket_metric.avatar_metrics]
}

# --- Billing (Virginia) ---

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_sns_topic" "billing_alerts_virginia" {
  provider = aws.virginia
  name     = "grocerymate-billing-alerts-virginia"
}

resource "aws_sns_topic_subscription" "billing_email_virginia" {
  provider  = aws.virginia
  topic_arn = aws_sns_topic.billing_alerts_virginia.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider            = aws.virginia
  alarm_name          = "GroceryMate-Monthly-Budget-Limit-30"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600"
  statistic           = "Maximum"
  threshold           = "30"
  alarm_description   = "Alert when total monthly charges exceed $30"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts_virginia.arn]
}

# --- Outputs (Fixed References) ---

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2.public_ip # FIXED: Points to module output
}

output "default_avatar_s3_url" {
  description = "Click this link to verify the default avatar is public"
  # FIXED: Construction of the URL using module output
  value       = "https://${module.storage.bucket_id}.s3.eu-central-1.amazonaws.com/avatars/user_default.png"
}