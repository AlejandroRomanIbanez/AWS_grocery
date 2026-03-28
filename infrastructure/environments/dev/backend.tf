# 0 - Remote Backend Configuration
# This stores the state file in S3 instead of locally on my Mac
terraform {
  backend "s3" {
    bucket = "grocerymate-tf-state-gajanan-x12"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"
  }
}