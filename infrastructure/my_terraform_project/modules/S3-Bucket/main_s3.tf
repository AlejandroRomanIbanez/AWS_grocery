# Create an S3 bucket for GroceryMate
resource "aws_s3_bucket" "grocerymate_bucket" {
  bucket = var.bucket_name  # The bucket name (must be globally unique)

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
  }
}

# Block all public access for security (highly recommended)
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.grocerymate_bucket.id

  block_public_acls       = true   # Block ACLs that make the bucket public
  block_public_policy     = true   # Block public bucket policies
  ignore_public_acls      = true   # Ignore any public ACLs
  restrict_public_buckets = true   # Restrict access to only authorized users
}
