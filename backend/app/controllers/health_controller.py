from flask import jsonify
from ..services.health_service import perform_health_check


def health_check():
    """
    Health check endpoint to verify network reachability and database connection.

    Returns:
        JSON response with status of API and database.
    """
    result = perform_health_check()
    status_code = 200 if result["status"] == "OK" else 500
    return jsonify(result), status_code
