output "bucket_id" {
  value = aws_s3_bucket.avatars.id
}

output "bucket_arn" {
  value = aws_s3_bucket.avatars.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

# --- CRUCIAL: The Brain needs this to give permissions to EC2 ---
output "ec2_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}