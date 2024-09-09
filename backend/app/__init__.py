from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_migrate import Migrate
from dotenv import load_dotenv
from datetime import timedelta
import os

load_dotenv()
db = SQLAlchemy()

class Config:
    """App configuration variables."""
    POSTGRES_URI = os.getenv("POSTGRES_URI")
    SQLALCHEMY_DATABASE_URI = POSTGRES_URI
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=4)


def create_app():
    """
    Creates and configures the Flask application.

    This function initializes the Flask app with necessary configurations, including
    enabling CORS, setting up JWT authentication, and registering blueprints for routes.

    Returns:
        Flask: The configured Flask application.
    """
    app = Flask(__name__)
    CORS(app, resources={r"/*": {"origins": "*"}})
    app.config.from_object(Config)

    db.init_app(app)
    JWTManager(app)
    Migrate(app, db)

    from .routes.auth_routes import auth_bp
    from .routes.user_routes import user_bp
    from .routes.product_routes import product_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(product_bp)

    return app
