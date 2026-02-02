import json
import urllib.parse
import boto3
import os

# Initialisierung des SNS-Clients
sns_client = boto3.client('sns')


def lambda_handler(event, context):
    """
    Diese Funktion wird durch einen S3-Upload getriggert.
    Sie extrahiert die Datei-Informationen und sendet eine
    Benachrichtigung über ein SNS-Topic.
    """

    # Extraktion von Bucket-Name und Dateischlüssel (Key) aus dem Event-Datensatz
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    # Zusammenbau der Benachrichtigung
    subject = "GroceryMate System-Benachrichtigung: Neuer Upload"
    message = (
        f"Ein neues Objekt wurde im S3-Bucket registriert.\n\n"
        f"Bucket: {bucket}\n"
        f"Datei: {key}\n"
        f"Status: Erfolgreich verarbeitet."
    )

    # Dynamische Ermittlung der SNS Topic ARN (wird über Umgebungsvariablen übergeben)
    topic_arn = os.environ.get('SNS_TOPIC_ARN')

    try:
        # Versand der Nachricht über SNS
        sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject
        )
        print(f"Benachrichtigung für {key} erfolgreich an SNS gesendet.")
    except Exception as e:
        print(f"Fehler beim Senden an SNS: {str(e)}")
        raise e

    return {
        'statusCode': 200,
        'body': json.dumps('Prozess erfolgreich abgeschlossen.')
    }