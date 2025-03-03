# Remote state setup (S3 backend)
terraform {
  backend "s3" {
    bucket         = "grocerymate-terraform-state" # S3 bucket for the remote state storage
    key            = "terraform/statefile.tfstate" # Path to the state file within the bucket
    region         = "eu-central-1"                # AWS region of your backend resources
    encrypt        = true                          # Encryption enabled for the state file
    dynamodb_table = "terraform-lock"              # DynamoDB table for state-locking
  }
}