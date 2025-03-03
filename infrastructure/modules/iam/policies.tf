# ✅ IAM Policy: Allow EC2 to Read from Secrets Manager
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerReadOnly"
  description = "Allows EC2 to read credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = var.db_credentials_secret_arn
    }]
  })
}

# ✅ IAM Policy: Allow Terraform to Manage State in S3 and DynamoDB Locks
resource "aws_iam_policy" "terraform_state_policy" {
  name        = "TerraformStateAccess"
  description = "Allows Terraform to manage state in S3 and DynamoDB locks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::grocerymate-terraform-state",
          "arn:aws:s3:::grocerymate-terraform-state/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = ["arn:aws:dynamodb:eu-central-1:324037288022:table/terraform-lock"]
      }
    ]
  })
}

# ✅ IAM Policy: Allow CloudWatch and SNS Access for Alarms
resource "aws_iam_policy" "cloudwatch_sns_policy" {
  name        = "CloudWatchSNSAccess"
  description = "Allows Terraform to manage CloudWatch Alarms and SNS notifications"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricAlarm",
          "sns:Publish"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Secrets Manager policy to EC2 role
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Attach Terraform state policy and CloudWatch/SNS policy to Terraform Execution Role
resource "aws_iam_role_policy_attachment" "attach_terraform_state_policy" {
  role       = "TerraformExecutionRole"
  policy_arn = aws_iam_policy.terraform_state_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_sns_policy" {
  role       = "TerraformExecutionRole"
  policy_arn = aws_iam_policy.cloudwatch_sns_policy.arn
}

# Policy for S3 pre-signed URLs and bucket listing
resource "aws_iam_policy" "s3_presigned_url_policy" {
  name        = "S3PresignedUrlPolicy"
  description = "Allows generating pre-signed URLs and listing S3 bucket contents"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::grocerymate-app-bucket/*"
      },
      {
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = "arn:aws:s3:::grocerymate-app-bucket"
      }
    ]
  })
}

# Attach S3 policy to the correct role (ec2_secrets_manager_role, not ec2_role)
resource "aws_iam_role_policy_attachment" "s3_presigned_url_attachment" {
  role       = aws_iam_role.ec2_secrets_manager_role.name  # Changed from ec2_role
  policy_arn = aws_iam_policy.s3_presigned_url_policy.arn
}