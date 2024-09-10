from sqlalchemy import text
from .. import db
from flask import current_app

def perform_health_check() -> dict:
    """
    Performs a health check by checking if the database is reachable.

    Returns:
        dict: A dictionary containing the status and message.
    """
    try:
        current_app.logger.info("Backend is reachable.")
        db.session.execute(text('SELECT 1'))
        current_app.logger.info("Database is reachable.")
        return {"status": "OK", "message": "Backend and database are reachable."}
    except Exception as e:
        current_app.logger.error(f"Health check failed: {e}")
        return {"status": "ERROR", "message": "Database unreachable."}
