# ✅ IAM Role for EC2 to Access AWS Secrets Manager
resource "aws_iam_role" "ec2_secrets_manager_role" {
  name = "grocerymate-ec2-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# ✅ IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocerymate-ec2-profile"
  role = aws_iam_role.ec2_secrets_manager_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "grocerymate-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}