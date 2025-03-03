# Data source for existing SSH Key Pair
data "aws_key_pair" "existing" {
  key_name = "grocerymate-key"
}

resource "aws_key_pair" "generated" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_rsa.pub") # Ensure you have an SSH key
}

# Data source for existing IAM Instance Profile
data "aws_iam_instance_profile" "existing" {
  name = "grocerymate-ec2-profile"
}

# Launch Template for ASG
resource "aws_launch_template" "grocery_app" {
  name_prefix   = "grocery-app-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.existing.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "GroceryMate App Running" > /var/www/html/index.html
              EOF
  )

  iam_instance_profile {
    name = data.aws_iam_instance_profile.existing.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
}

resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = element(var.public_subnets, 0)
  vpc_security_group_ids = [var.bastion_security_group_id]
  key_name               = aws_key_pair.generated.key_name
  iam_instance_profile   = data.aws_iam_instance_profile.existing.name  # Added this line

  associate_public_ip_address = true # Ensures a public IP

  tags = {
    Name = "BastionHost"
  }
}