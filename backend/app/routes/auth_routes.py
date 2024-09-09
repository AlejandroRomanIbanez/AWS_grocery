from flask import Blueprint
from app.controllers.auth_controller import register, login

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

auth_bp.route('/register', methods=['POST'])(register)
auth_bp.route('/login', methods=['POST'])(login)
