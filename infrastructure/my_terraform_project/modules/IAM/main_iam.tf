# Create IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "grocerymate-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "ec2-role"
  }
}

# Attach managed policy for basic EC2 access to CloudWatch Logs
resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create instance profile to attach the IAM role to EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "grocerymate-instance-profile"
  role = aws_iam_role.ec2_role.name
}
