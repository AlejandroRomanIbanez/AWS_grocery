import logging
import shutil
import tempfile
import zipfile
from logging.handlers import RotatingFileHandler
import os
import socket
from flask import Flask, send_from_directory, render_template, request
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from sqlalchemy import text
from flask_migrate import Migrate
from dotenv import load_dotenv
from datetime import timedelta
import requests
from dateutil import parser

load_dotenv()
db = SQLAlchemy()

DEPLOYMENT_ENV = os.getenv("DEPLOYMENT_ENV", "local")
GITHUB_USERNAME = "AlejandroRomanIbanez"
REPO_NAME = "AWS_grocery"
FRONTEND_BUILD_ZIP = "frontend-build.zip"
FRONTEND_BUILD_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../frontend/build"))
TMP_ZIP_PATH = os.path.join(tempfile.gettempdir(), "frontend-build.zip")
GITHUB_RELEASE_URL = f"https://github.com/{GITHUB_USERNAME}/{REPO_NAME}/releases/latest/download/{FRONTEND_BUILD_ZIP}"


class Config:
    """App configuration variables."""
    POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_DB = os.getenv("POSTGRES_DB", "postgres")
    POSTGRES_HOST = os.getenv("POSTGRES_HOST", "postgres")
    POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")

    POSTGRES_URI = os.getenv("POSTGRES_URI", "postgresql://postgres:postgres@localhost:5432/postgres")

    if not POSTGRES_URI:
        raise ValueError("POSTGRES_URI environment variable is not set.")

    @classmethod
    def is_rds(cls):
        """Check if using AWS RDS by detecting an external hostname."""
        rds_hostnames = ["rds.amazonaws.com", "amazonaws.com"]
        return any(h in cls.POSTGRES_URI for h in rds_hostnames)

    @classmethod
    def is_local_postgres(cls):
        """Check if 'postgres' resolves to a local Docker container."""
        return not cls.is_rds()

    SQLALCHEMY_DATABASE_URI = POSTGRES_URI
    print(f"Using Database: {SQLALCHEMY_DATABASE_URI}")

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=4)


def detect_environment():
    if Config.is_rds():
        print("Running on AWS RDS (Production)")
    elif Config.is_local_postgres():
        print("Running in Local Docker PostgreSQL")
    else:
        print("Could not detect database environment. Set POSTGRES_URI manually.")
    print(f"Using Database: {Config.SQLALCHEMY_DATABASE_URI}")


detect_environment()


def fetch_frontend():
    """
    Fetches the latest frontend build from GitHub Releases and ensures it's placed in frontend/build.
    """
    if os.path.exists(FRONTEND_BUILD_PATH):
        print("Frontend build is already present. Checking for updates...")
        latest_release_timestamp = get_github_release_timestamp()
        local_build_timestamp = get_local_build_timestamp()

        if latest_release_timestamp and local_build_timestamp:
            if local_build_timestamp >= latest_release_timestamp:
                print("Frontend build is up to date.")
                return
            print("Frontend build is outdated. Fetching the latest version...")
    else:
        print("Frontend build not found. Fetching the latest version...")

    try:
        response = requests.get(GITHUB_RELEASE_URL, stream=True)
        if response.status_code == 200:
            # Save the zip file
            with open(TMP_ZIP_PATH, "wb") as f:
                f.write(response.content)

            # Ensure frontend directory exists
            frontend_dir = os.path.dirname(FRONTEND_BUILD_PATH)
            os.makedirs(frontend_dir, exist_ok=True)

            # Create temporary extraction directory
            temp_extract_path = os.path.join(frontend_dir, "temp_extract")
            shutil.rmtree(temp_extract_path, ignore_errors=True)
            os.makedirs(temp_extract_path)

            # First, extract to temp directory
            with zipfile.ZipFile(TMP_ZIP_PATH, 'r') as zip_ref:
                zip_ref.extractall(temp_extract_path)

            # Clear existing build directory if it exists
            if os.path.exists(FRONTEND_BUILD_PATH):
                shutil.rmtree(FRONTEND_BUILD_PATH)

            # Create fresh build directory
            os.makedirs(FRONTEND_BUILD_PATH)

            # Determine source of files
            if os.path.exists(os.path.join(temp_extract_path, "build", "index.html")):
                # Files are in a build subdirectory
                source_dir = os.path.join(temp_extract_path, "build")
                print("Found build directory in zip, using its contents")
            elif os.path.exists(os.path.join(temp_extract_path, "index.html")):
                # Files are at root
                source_dir = temp_extract_path
                print("Found files at root of zip, moving them to build directory")
            else:
                raise Exception("Could not find index.html in the extracted content")

            # Copy everything to build directory
            for item in os.listdir(source_dir):
                source = os.path.join(source_dir, item)
                dest = os.path.join(FRONTEND_BUILD_PATH, item)
                if os.path.isdir(source):
                    shutil.copytree(source, dest)
                else:
                    shutil.copy2(source, dest)

            print("Frontend files successfully moved to build directory")

            # Verify the build directory has expected files
            if not os.path.exists(os.path.join(FRONTEND_BUILD_PATH, "index.html")):
                raise Exception("Failed to find index.html in final build directory")

            # Clean up
            shutil.rmtree(temp_extract_path, ignore_errors=True)
            os.remove(TMP_ZIP_PATH)

            print("Frontend build downloaded and extracted successfully")
        else:
            print(f"Failed to download frontend build. Status Code: {response.status_code}")
    except Exception as e:
        print(f"Error fetching frontend: {e}")
        # Clean up on error
        if 'temp_extract_path' in locals():
            shutil.rmtree(temp_extract_path, ignore_errors=True)
        if os.path.exists(TMP_ZIP_PATH):
            os.remove(TMP_ZIP_PATH)
        # Keep existing build if update fails
        raise


def get_github_release_timestamp():
    """
    Fetches the timestamp of the latest frontend release from GitHub.
    """
    release_api_url = f"https://api.github.com/repos/{GITHUB_USERNAME}/{REPO_NAME}/releases/latest"
    try:
        response = requests.get(release_api_url)
        if response.status_code == 200:
            timestamp_iso = response.json().get("published_at")
            if timestamp_iso:
                return int(parser.parse(timestamp_iso).timestamp())
    except Exception as e:
        print(f"Error fetching GitHub release timestamp: {e}")
    return None


def get_local_build_timestamp():
    """
    Retrieves the timestamp of the local frontend build.
    """
    try:
        return os.path.getmtime(FRONTEND_BUILD_PATH)
    except Exception:
        return None


def create_app():
    """
    Creates and configures the Flask app.
    """
    fetch_frontend()

    app = Flask(__name__,
                static_folder="../../frontend/build/static",
                template_folder=os.path.join(os.path.dirname(__file__), "../../frontend/build"))
    CORS(app, resources={r"/*": {"origins": "*"}})
    app.config.from_object(Config)

    db.init_app(app)

    with app.app_context():
        if app.config['SQLALCHEMY_DATABASE_URI'].startswith('sqlite'):
            db.session.execute(text('PRAGMA foreign_keys=ON'))

    JWTManager(app)
    Migrate(app, db)
    setup_logging(app)

    from .routes.auth_routes import auth_bp
    from .routes.user_routes import user_bp
    from .routes.product_routes import product_bp
    from .routes.health_routes import health_bp
    from .routes.config_routes import config_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(user_bp)
    app.register_blueprint(product_bp)
    app.register_blueprint(health_bp)
    app.register_blueprint(config_bp)

    def inject_backend_url():
        """Get the backend URL based on the current request, works dynamically in all environments."""
        proto = request.headers.get('X-Forwarded-Proto', request.scheme)
        host = request.headers.get('X-Forwarded-Host', request.host)
        print(f"Resolved URL - Proto: {proto}, Host: {host}")
        return f"{proto}://{host}"

    @app.route("/", defaults={"path": ""})
    @app.route("/<path:path>")
    def serve_react_app(path):
        if path != "" and os.path.exists(os.path.join(app.static_folder, path)):
            return send_from_directory(app.static_folder, path)
        else:
            backend_url = inject_backend_url()
            return render_template(
                "index.html",
                backend_url=backend_url
            )

    return app


def setup_logging(app):
    """
    Set up logging to a file, creating the log file if it doesn't exist.
    Logs will rotate when they reach a certain size.
    """
    if not os.path.exists('logs'):
        os.mkdir('logs')

    log_file = 'logs/app.log'

    file_handler = RotatingFileHandler(log_file, maxBytes=1024 * 1024, backupCount=5)
    file_handler.setLevel(logging.INFO)

    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    file_handler.setFormatter(formatter)

    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)