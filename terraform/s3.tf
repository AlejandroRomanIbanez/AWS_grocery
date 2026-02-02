# Erstellt den S3-Speicherbehälter (Bucket)
resource "aws_s3_bucket" "avatar_bucket" {
  bucket = "grocery-yssf"                            # Der weltweit eindeutige Name des Buckets

  # Metadaten zur Organisation der Ressourcen
  tags = {
    Name        = "grocery_shop_bucket"              # Anzeigename in der AWS Konsole
    Environment = "Dev"                              # Kennzeichnung als Entwicklungsumgebung
  }
}

# Erstellt eine virtuelle Ordnerstruktur innerhalb des Buckets
resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.avatar_bucket.id            # Verweist auf den oben erstellten Bucket
  key    = "avatars/"                                # Das "/" am Ende signalisiert AWS, dass dies ein Ordner ist
}

# Lädt eine konkrete Datei in den S3-Bucket hoch
resource "aws_s3_object" "default_avatar" {
  bucket       = aws_s3_bucket.avatar_bucket.id      # Ziel-Bucket für den Upload
  key          = "avatars/images_avatar_aws.png"     # Zielpfad und Dateiname innerhalb von S3
  source       = "images_avatar_aws.png"             # Pfad zur Datei auf deinem lokalen Rechner
  content_type = "image/png"                         # Definiert den Dateityp (wichtig für die Anzeige im Browser)
}