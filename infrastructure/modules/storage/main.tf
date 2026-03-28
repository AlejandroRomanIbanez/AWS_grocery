# 6. S3 Bucket for User Avatars
resource "aws_s3_bucket" "avatars" {
  bucket = var.avatar_bucket_name
  force_destroy = true
  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}

# 7. IAM Role for EC2 to access S3
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "grocery-ec2-role-gajanan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach S3 Full Access Policy to the Role
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create the Instance Profile (The "Badge" for EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocery_ec2_profile_gajanan"
  role = aws_iam_role.ec2_s3_access_role.name
}

# 8. This block disables the default "Block Public Access"  settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 9. This block grants "GetObject" (Read) permission to everyone (*)
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.avatars.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        # This "/*" is the magic fix
        Resource = [
             "${aws_s3_bucket.avatars.arn}/avatars/*"
        ]
      }
    ]
  })
  # This line is important! It ensures the "unlock" happens before the policy is applied
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# 10. Add default image to created S3 bucket:
resource "aws_s3_object" "default_avatar" {
bucket       = aws_s3_bucket.avatars.id
key          = "avatars/user_default.png"
source = "${path.root}/../../../backend/avatar/user_default.png"
content_type = "image/png"
depends_on   = [aws_s3_bucket_policy.public_read_policy]
}

# 11. Enable Versioning (Keeps a history of the same filename)
resource "aws_s3_bucket_versioning" "avatar_versioning" {
bucket = aws_s3_bucket.avatars.id
versioning_configuration {
status = "Enabled"
}
}

# 12. The "Trash Collector" (Deletes everything but the current photo after 1 day)
resource "aws_s3_bucket_lifecycle_configuration" "avatar_lifecycle" {
  bucket = aws_s3_bucket.avatars.id

  rule {
    id     = "cleanup_old_versions"
    status = "Enabled"

    # This tells S3 to only look inside your "avatars" folder
    filter {
      prefix = "avatars/"
    }

    # This deletes 'non-current' (old) versions after 1 day
    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    # Optional: Cleans up failed uploads to save money
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
