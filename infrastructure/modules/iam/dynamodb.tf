/*
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "Terraform Lock Table"
  }
}
*/

data "aws_dynamodb_table" "existing" {
  name = "terraform-lock"
}