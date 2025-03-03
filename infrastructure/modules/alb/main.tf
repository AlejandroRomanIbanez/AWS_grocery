# Define the Application Load Balancer
resource "aws_lb" "grocerymate_alb" {
  name               = "grocerymate-alb"          # Unique name for the ALB
  internal           = false                      # External ALB for public access
  load_balancer_type = "application"              # Specifies this is an ALB
  security_groups    = [var.alb_security_group_id] # Dedicated SG for ALB (allows HTTP/HTTPS only)
  subnets            = var.public_subnets         # Place ALB in public subnets
  tags = {
    Name = "GroceryMate-ALB"                      # Consistent tagging
  }
}

# Define the Target Group for forwarding traffic
resource "aws_lb_target_group" "grocerymate_tg" {
  name     = "grocerymate-target-group"           # Unique name for the target group
  port     = 80                                   # Forward traffic to port 80 on instances
  protocol = "HTTP"                               # Use HTTP protocol
  vpc_id   = var.vpc_id                           # Tie to your VPC
  health_check {
    path                = "/"                     # Check root path for instance health
    interval            = 30                      # Check every 30 seconds
    timeout             = 5                       # Wait 5 seconds for a response
    healthy_threshold   = 2                       # Mark healthy after 2 successes (faster detection)
    unhealthy_threshold = 2                       # Mark unhealthy after 2 failures (faster failover)
  }
}

# Define the Listener for HTTP traffic
resource "aws_lb_listener" "grocerymate_http" {
  load_balancer_arn = aws_lb.grocerymate_alb.arn  # Link to the ALB
  port              = 80                          # Listen on port 80
  protocol          = "HTTP"                      # Use HTTP (consider HTTPS for production)
  default_action {
    type             = "forward"                  # Forward traffic to the target group
    target_group_arn = aws_lb_target_group.grocerymate_tg.arn # Target group to receive traffic
  }
}

