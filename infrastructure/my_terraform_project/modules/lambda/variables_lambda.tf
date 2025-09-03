# ALB DNS name to insert into the Python script
variable "alb_dns_name" {
  description = "The DNS name of the ALB to perform health checks on"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "grocerymate-health-check"
}

variable "lambda_runtime" {
  description = "Runtime environment for Lambda"
  type        = string
  default     = "python3.10"
}

variable "lambda_zip_path" {
  description = "Path to the ZIP file containing Lambda code"
  type        = string
  default     = "build/lambda.zip"
}
