from flask import request, jsonify
from flask_jwt_extended import create_access_token
from pydantic import ValidationError

from app.helpers import serialize_object_id, format_validation_error
from app.models.user_model import UserRegistration, UserLogin
from app.services.auth_service import register_user, login_user


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
    except ValidationError as e:
        formatted_error = format_validation_error(e)
        return jsonify({'error': formatted_error}), 400

    data_serialized = serialize_object_id(data)

    response, status = register_user(data_serialized)

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
        # Attempt to parse and validate the incoming data against the UserLogin model
        data = UserLogin(**request.get_json())
    except ValidationError as e:
        # If validation fails, format the error and return a 400 Bad Request response
        formatted_error = format_validation_error(e)
        return jsonify({'error': formatted_error}), 400

        # Authenticate the user
    user = login_user(data)
    if 'error' in user:
        return jsonify(user), 401  # Return 401 if authentication fails

    # Create access token if authentication is successful
    access_token = create_access_token(identity=str(user['_id']))
    return jsonify({'access_token': access_token}), 200  # Return 200 OK with the access token
