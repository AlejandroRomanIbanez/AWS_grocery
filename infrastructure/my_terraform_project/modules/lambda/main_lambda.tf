
# Render the Lambda Python script with ALB DNS injected
resource "local_file" "lambda_script" {
  content  = templatefile("${path.module}/../../scripts/lambda_health_check_template.py", {
    alb_dns = var.alb_dns_name
  })

  filename = "${path.module}/lambda/lambda_health_check.py"
}

# IAM role for Lambda (basic permissions for logs etc.)
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambda function from ZIP (must be built with build_lambda_zip.sh)
resource "aws_lambda_function" "health_check" {
  filename         = var.lambda_zip_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      ENV = "dev"
    }
  }
}


# Create a CloudWatch EventBridge rule to trigger Lambda every 5 minutes
resource "aws_cloudwatch_event_rule" "every_5_minutes" {
  name                = "lambda-health-check-schedule"
  description         = "Triggers Lambda health check every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

# Grant permissions so EventBridge can invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_5_minutes.arn
}

# Connect the rule to the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_5_minutes.name
  target_id = "lambda-health-check"
  arn       = aws_lambda_function.health_check.arn
}
