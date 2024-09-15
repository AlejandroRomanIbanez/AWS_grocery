from flask import current_app
from werkzeug.security import generate_password_hash, check_password_hash
from ..models.user_model import User
from .. import db


def register_user(data):
    """
    Register a new user in the database.

    Hashes the user's password and stores the user information in the database.
    Checks if the username or email already exists.

    Args:
        data (UserRegistration): User registration data.

    Returns:
        tuple: JSON response message and HTTP status code.
    """
    username = data.username
    email = data.email
    password = generate_password_hash(data.password)

    current_app.logger.info(f"Attempting to register user: {username}")

    if User.query.filter_by(username=username).first():
        current_app.logger.warning(f"Username {username} already exists.")
        return {'error': 'Username already exists'}, 400

    if User.query.filter_by(email=email).first():
        current_app.logger.warning(f"Email {email} already exists.")
        return {'error': 'Email already exists'}, 400

    new_user = User(username=username, email=email, password=password)
    db.session.add(new_user)
    db.session.commit()

    current_app.logger.info(f"User {username} registered successfully.")
    return {'message': 'User registered successfully'}, 201


def login_user(data):
    """
    Authenticate a user.

    Verifies the user's email and password against the database records.

    Args:
        data (UserLogin): User login data.

    Returns:
        dict: User data if authentication is successful, otherwise an error message.
    """
    email = data.email
    password = data.password

    current_app.logger.info(f"Attempting to login user: {email}")

    user = User.query.filter_by(email=email).first()

    if not user or not check_password_hash(user.password, password):
        current_app.logger.warning(f"Invalid login attempt for user {email}")
        return {'error': 'Invalid username or password'}

    current_app.logger.info(f"User {user.username} authenticated successfully.")
    return {
        '_id': user.id,
        'username': user.username,
        'email': user.email,
        'fav_products': user.fav_products,
        'purchased_products': user.purchased_products
    }
