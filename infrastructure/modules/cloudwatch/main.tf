# SNS Topic for CloudWatch Alarm Notifications
resource "aws_sns_topic" "cloudwatch_notifications" {
  name = "cloudwatch-alarms"
}

# SNS Subscription for Email Notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_notifications.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"  # Replace with your email for notifications
}

# CloudWatch Alarm for EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "ec2-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"  # 5 minutes
  statistic           = "Average"
  threshold           = "80"   # Trigger if CPU > 80%
  alarm_description   = "This alarm triggers when EC2 CPU utilization exceeds 80% for 2 consecutive periods"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]

  dimensions = {
    InstanceId = module.ec2.instance_id  # Reference EC2 instance ID from module.ec2
  }
}

# CloudWatch Alarm for ALB Healthy Host Count (ensure ALB has healthy targets)
resource "aws_cloudwatch_metric_alarm" "alb_healthy_host_alarm" {
  alarm_name          = "alb-unhealthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"  # 5 minutes
  statistic           = "Average"
  threshold           = "1"    # Trigger if fewer than 1 healthy host
  alarm_description   = "This alarm triggers when ALB has fewer than 1 healthy host for 2 consecutive periods"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]

  dimensions = {
    LoadBalancer = module.alb.alb_name  # Reference ALB name from module.alb
  }
}

# CloudWatch Alarm for RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = "rds-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"  # 5 minutes
  statistic           = "Average"
  threshold           = "80"   # Trigger if CPU > 80%
  alarm_description   = "This alarm triggers when RDS CPU utilization exceeds 80% for 2 consecutive periods"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]

  dimensions = {
    DBInstanceIdentifier = module.rds.rds_identifier  # Reference RDS identifier from module.rds
  }
}

# CloudWatch Alarm for ASG Minimum Capacity (ensure desired capacity is met)
resource "aws_cloudwatch_metric_alarm" "asg_capacity_alarm" {
  alarm_name          = "asg-low-capacity"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "GroupMinSize"
  namespace           = "AWS/AutoScaling"
  period              = "300"  # 5 minutes
  statistic           = "Average"
  threshold           = "1"    # Trigger if min size < 1
  alarm_description   = "This alarm triggers when ASG minimum capacity falls below 1 for 2 consecutive periods"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]

  dimensions = {
    AutoScalingGroupName = module.asg.asg_name  # Reference ASG name from module.asg
  }
}