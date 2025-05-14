# S3_bucket erstellen
resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatars-christinakloos"

  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}

# S3_bucket privat definieren, d. h. explizit den öffentlichen Zugriff blockieren
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versionierung definieren
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.avatars.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM-Rolle erstellen, damit EC2 Zugriff auf S3 hat
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy für Zugriff auf S3_bucket
resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "ec2_s3_access_policy"
  description = "Allow EC2 instances to access grocerymate-avatars S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.avatars.arn,
          "${aws_s3_bucket.avatars.arn}/*"
        ]
      }
    ]
  })
}


# IAM Policy an Role anhängen
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_instance_profile"
  role = aws_iam_role.ec2_s3_role.name
}



