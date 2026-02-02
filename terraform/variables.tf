variable "user_email" {
  description = "E-Mail für SNS Benachrichtigungen"
  type        = string
}

variable "db_password" {
  description = "Das Passwort für die RDS Datenbank"
  type        = string
  sensitive   = true  # Verhindert, dass das Passwort im Log angezeigt wird
}