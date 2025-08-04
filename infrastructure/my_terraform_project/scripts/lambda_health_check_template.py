import json          # Used to format the response as JSON
import urllib3       # Lightweight HTTP client library for making HTTP requests

# Create an HTTP connection pool manager
http = urllib3.PoolManager()

# Main Lambda handler function – triggered automatically by AWS (e.g., via CloudWatch Events)
def lambda_handler(event, context):
    url = "http://{alb_dns}"  # Target URL (this should be the ALB DNS name) – passed dynamically via Terraform

    try:
        # Send a GET request to the target URL
        response = http.request("GET", url)
        status = response.status  # Get the HTTP status code from the response

        # Create a log message with the result of the health check
        message = f"Health check: {url} returned status {status}"

        # Check if the status code indicates success (HTTP 200 OK)
        if status == 200:
            print("[SUCCESS]", message)  # Log a success message to CloudWatch
        else:
            print("[ERROR]", message)    # Log an error message to CloudWatch if the app is not healthy

    except Exception as e:
        # If there was any exception (e.g., DNS error, timeout), log the error
        print("[EXCEPTION] Error checking health:", str(e))

    # Always return a 200 status for Lambda itself (regardless of target health)
    return {
        "statusCode": 200,
        "body": json.dumps("Health check completed.")  # Body is required for HTTP API compatibility
    }
