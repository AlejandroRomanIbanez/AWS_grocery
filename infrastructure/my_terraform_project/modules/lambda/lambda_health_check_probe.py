import json
import urllib3

http = urllib3.PoolManager()


def lambda_handler(event, context):
    url = "http://google.com"  # <--z. B. google.com manuell einsetzen

    try:
        response = http.request("GET", url)
        status = response.status
        message = f"Health check: {url} returned status {status}"

        if status == 200:
            print("[SUCCESS]", message)
        else:
            print("[ERROR]", message)
    except Exception as e:
        print("[EXCEPTION] Error checking health:", str(e))

    return {
        "statusCode": 200,
        "body": json.dumps("Health check completed.")
    }
