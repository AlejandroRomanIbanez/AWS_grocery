from werkzeug.security import generate_password_hash, check_password_hash
from app import mongo
from app.helpers import serialize_object_id


def register_user(data):
    """
    Register a new user in the database.

    Hashes the user's password and stores the user information in the database.
    Checks if the username already exists.

    Args:
        data (UserRegistration): User registration data.

    Returns:
        tuple: JSON response message and HTTP status code.
    """
    username = data.username
    email = data.email
    password = generate_password_hash(data.password)

    if mongo.grocery.users.find_one({'username': username}):
        return {'error': 'Username already exists'}, 400

    mongo.grocery.users.insert_one({'email': email,
                                    'username': username,
                                    'password': password,
                                    'basket': [],
                                    'fav_products': []})
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

    user = mongo.grocery.users.find_one({'email': email})
    if not user or not check_password_hash(user['password'], password):
        return {'error': 'Invalid username or password'}

    return serialize_object_id(user)
