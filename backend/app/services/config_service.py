import os

def fetch_config():
    """
    Retrieves configuration settings dynamically from the environment variables.

    Returns:
        dict: A dictionary containing configuration settings.
    """
    return {
        "USE_S3_STORAGE": os.getenv("USE_S3_STORAGE", "false") == "true",
        "S3_BUCKET": os.getenv("S3_BUCKET_NAME", ""),
        "S3_REGION": os.getenv("S3_REGION", ""),
    }
