from flask import request, jsonify, current_app
from flask_jwt_extended import create_access_token
from pydantic import ValidationError

from ..helpers import format_validation_error
from ..models.user_model import UserRegistration, UserLogin
from ..services.auth_service import register_user, login_user


def register():
    """
        Register a new user.

        Receives user registration data from the request, registers the user,
        and returns a JSON response with a success or error message and an HTTP status code.

        Returns:
            tuple: JSON response and HTTP status code.
    """
    try:
        data = UserRegistration(**request.get_json())
        current_app.logger.info(f"Received registration data for user: {data.username}")
    except ValidationError as e:
        formatted_error = format_validation_error(e)
        current_app.logger.error(f"Validation error during registration: {formatted_error}")
        return jsonify({'error': formatted_error}), 400

    response, status = register_user(data)

    if status == 201:
        current_app.logger.info(f"User {data.username} registered successfully.")
    else:
        current_app.logger.warning(f"Failed to register user {data.username}: {response['error']}")

    return jsonify(response), status


def login():
    """
    Login a user.

    Receives user login data from the request, authenticates the user,
    and returns a JSON response with an access token or an error message and an HTTP status code.

    Returns:
        tuple: JSON response and HTTP status code.
    """
    try:
        data = UserLogin(**request.get_json())
        current_app.logger.info(f"Received login attempt for user: {data.email}")
    except ValidationError as e:
        formatted_error = format_validation_error(e)
        current_app.logger.error(f"Validation error during login: {formatted_error}")
        return jsonify({'error': formatted_error}), 400

    user = login_user(data)
    if 'error' in user:
        current_app.logger.warning(f"Login failed for user {data.email}: {user['error']}")
        return jsonify(user), 401

    access_token = create_access_token(identity=str(user['_id']))
    current_app.logger.info(f"User {user['username']} logged in successfully.")
    return jsonify({'access_token': access_token}), 200
