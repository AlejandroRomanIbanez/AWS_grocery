from flask import Blueprint
from ..controllers.config_controller import get_config

config_bp = Blueprint("config", __name__, url_prefix="/api/config")

config_bp.route("/", methods=["GET"])(get_config)
