# Generate SSH Key Pair using public key
resource "aws_key_pair" "terraform_ssh_key" {
  key_name   = "terraform_ssh_key"  # Name in AWS Console
  public_key = file(var.public_key_path)  # Read from .pub file
}


# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami                    = var.ami_id                       # Amazon Machine Image ID
  instance_type          = var.instance_type                # Type of EC2 instance (t2.micro)
  subnet_id              = var.public_subnet_id             # Subnet to launch the instance in
  key_name = aws_key_pair.terraform_ssh_key.key_name        # SSH key pair name
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]  # Attach security group

  user_data              = var.user_data_script     # Startup script (install Docker)
  iam_instance_profile   = var.iam_instance_profile # Attach IAM Profile

  tags = {
    Name = "ec2-grocerymate"
  }
}

# Create a security group for the EC2 instance
resource "aws_security_group" "web_server_sg" {
  name        = "ec2-sg-grocerymate"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = var.vpc_id

  # Allow SSH (port 22) from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (port 80) from anywhere
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-grocerymate"
  }
}
