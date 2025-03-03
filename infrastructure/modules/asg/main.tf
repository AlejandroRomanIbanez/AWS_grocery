# Define the Auto Scaling Group
resource "aws_autoscaling_group" "grocery_asg" {
  name                = "grocery-asg"           # Unique name for the ASG
  desired_capacity    = 2                       # Initial number of instances
  max_size            = 4                       # Maximum number of instances allowed
  min_size            = 1                       # Minimum number of instances to maintain
  vpc_zone_identifier = var.subnet_ids          # Private subnet IDs where instances will launch
  target_group_arns   = [var.target_group_arn]  # Attach ASG to the Application Load Balancer (ALB) target group

  launch_template {
    id      = var.launch_template_id            # Reference the launch template ID from the EC2 module
    version = var.launch_template_version       # Use the latest version of the launch template
  }

  # Health check configuration for ELB
  health_check_type        = "ELB"              # Use Elastic Load Balancer for health checks
  health_check_grace_period = 300               # Grace period (in seconds) before health checks start

  # Tag instances launched by the ASG for easy identification
  tag {
    key                 = "Name"
    value               = "GroceryASGInstance"
    propagate_at_launch = true                  # Apply this tag to all instances launched by the ASG
  }

  # Optional: Force deletion of the ASG and its instances if needed
  force_delete = false                          # Do not force delete unless explicitly required

  # Ensure the ASG waits for capacity to be satisfied before marking as complete
  wait_for_capacity_timeout = "10m"             # Wait up to 10 minutes for capacity

  # Optional: Protect instances from scale-in by default (can be overridden)
  protect_from_scale_in = false
}