# Create a security group for the ALB (allowing HTTP from anywhere)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-grocerymate"
  description = "Allow HTTP access to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-grocerymate"
  }
}

# Create a target group for the ALB to route traffic to EC2 instances
resource "aws_lb_target_group" "app_tg" {
  name     = "grocerymate-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "grocerymate-target-group"
  }
}

# Create the Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "grocerymate-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "grocerymate-alb"
  }
}

# Create a listener on port 80 that forwards to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Launch Template for EC2 instances in ASG
resource "aws_launch_template" "web_template" {
  name_prefix   = "grocerymate-launch-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(var.user_data_script)

  vpc_security_group_ids = [var.ec2_security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "grocerymate-instance"
    }
  }
}

# Auto Scaling Group using the Launch Template
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = var.public_subnet_ids
  target_group_arns    = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "grocerymate-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
