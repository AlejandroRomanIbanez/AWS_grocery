from flask import jsonify
from ..services.config_service import fetch_config

def get_config():
    """
    Retrieves the application's configuration settings dynamically.
    """
    config_data = fetch_config()
    return jsonify(config_data), 200
