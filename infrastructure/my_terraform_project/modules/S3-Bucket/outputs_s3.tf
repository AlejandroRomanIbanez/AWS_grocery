# Output the S3 bucket name
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.grocerymate_bucket.bucket
}

# Output the S3 bucket ARN (Amazon Resource Name)
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.grocerymate_bucket.arn
}
