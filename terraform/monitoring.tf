# --- LAMBDA ARTEFAKT ERSTELLEN ---
# Komprimiert das Python-Skript in ein ZIP-Archiv, da AWS Lambda den Code in diesem Format erwartet.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# --- LAMBDA FUNKTION ---
# Definiert die Serverless-Funktion, die auf S3-Events reagiert.
resource "aws_lambda_function" "image_logger" {
  filename         = "lambda_function.zip"
  function_name    = "grocery-image-logger"
  role             = aws_iam_role.grocery_ec2_role.arn
  handler          = "lambda_function.lambda_handler" # Verweist auf Dateiname.Funktionsname
  runtime          = "python3.11"

  # Stellt sicher, dass die Funktion bei Code-Änderungen neu hochgeladen wird
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Übergabe der SNS-Topic-ARN als Umgebungsvariable für den Python-Code
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.grocery_alerts.arn
    }
  }
}

# --- SNS INFRASTRUKTUR ---
# Erstellt einen Nachrichten-Kanal (Topic) für System-Benachrichtigungen.
resource "aws_sns_topic" "grocery_alerts" {
  name = "grocery-system-alerts"
}

# Registriert eine E-Mail-Adresse für den Empfang von Benachrichtigungen aus dem Topic.
resource "aws_sns_topic_subscription" "user_email_sub" {
  topic_arn = aws_sns_topic.grocery_alerts.arn
  protocol  = "email"
  endpoint = var.user_email
}

# --- SICHERHEIT & BERECHTIGUNGEN ---
# Erteilt dem S3-Dienst explizit die Berechtigung, die Lambda-Funktion auszuführen.
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_logger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.avatar_bucket.arn
}

# --- S3 EVENT TRIGGER ---
# Konfiguriert den S3-Bucket so, dass bei neuen Objekten eine Benachrichtigung an Lambda erfolgt.
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.avatar_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_logger.arn
    events              = ["s3:ObjectCreated:*"] # Reagiert auf alle "Upload"-Events
    filter_prefix       = "avatars/"           # Filtert auf den spezifischen Ordner
  }

  # Stellt sicher, dass die Berechtigung existiert, bevor der Trigger erstellt wird
  depends_on = [aws_lambda_permission.allow_s3]
}


# --- CLOUDWATCH ALARM ---
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "High-CPU-Usage-Grocery-Server"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120" # 2 Minuten
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Dieser Alarm wird ausgelöst, wenn die CPU-Last über 80% steigt."

  dimensions = {
    InstanceId = aws_instance.grocery_server.id
  }

  alarm_actions = [aws_sns_topic.grocery_alerts.arn]
}