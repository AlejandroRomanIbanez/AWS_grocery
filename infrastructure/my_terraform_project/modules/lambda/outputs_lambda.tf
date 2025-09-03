# Output the name of the Lambda function
output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.health_check.function_name
}

# Output the ARN (Amazon Resource Name) of the Lambda function
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.health_check.arn
}


# Output the IAM role name used by the Lambda function
output "lambda_exec_role_name" {
  description = "The name of the IAM role used by the Lambda function"
  value       = aws_iam_role.lambda_exec_role.name
}