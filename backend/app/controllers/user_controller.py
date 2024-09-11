from flask import jsonify, request, current_app, send_from_directory
from flask_jwt_extended import get_jwt_identity, jwt_required
from ..services.user_service import add_to_favorites, get_user_favorites, remove_from_favorites, sync_basket_service, \
    get_user_basket, remove_from_basket_service, add_product_to_purchased, get_user_purchased_products, get_user_info, \
    clear_user_basket, save_avatar, UPLOAD_FOLDER, get_all_users


@jwt_required()
def get_all_users_info():
    """
    Retrieves information of all users.

    Returns:
        JSON: A JSON response containing the list of all users and their information.
    """
    current_app.logger.info("Fetching information for all users.")
    users_info = get_all_users()
    return jsonify(users_info), 200

@jwt_required()
def get_current_user_info():
    """
    Retrieves the current user's information.

    Returns:
        JSON: A JSON response containing the user's information.
    """
    user_id = get_jwt_identity()
    current_app.logger.info(f"Fetching info for user {user_id}.")

    user_info = get_user_info(user_id)
    if user_info:
        current_app.logger.info(f"User info for {user_id} retrieved successfully.")
        return jsonify(user_info), 200

    current_app.logger.warning(f"User with ID {user_id} not found.")
    return jsonify({"error": "User not found"}), 404


@jwt_required()
def add_favorite():
    """
    Adds a product to the user's list of favorite products.

    Returns:
        JSON: A JSON response indicating success or failure.
    """
    user_id = get_jwt_identity()
    product_id = request.json.get("product_id")
    current_app.logger.info(f"User {user_id} attempting to add product {product_id} to favorites.")

    result = add_to_favorites(user_id, product_id)
    if "error" not in result:
        current_app.logger.info(f"Product {product_id} added to favorites for user {user_id}.")
        return jsonify({"message": "Product added to favorites"}), 201

    current_app.logger.warning(f"Failed to add product {product_id} to favorites for user {user_id}: {result['error']}")
    return jsonify(result), 400


@jwt_required()
def remove_favorite():
    """
    Removes a product from the user's list of favorite products.

    Returns:
        JSON: A JSON response indicating success or failure.
    """
    user_id = get_jwt_identity()
    product_id = request.json.get("product_id")
    current_app.logger.info(f"User {user_id} attempting to remove product {product_id} from favorites.")

    result = remove_from_favorites(user_id, product_id)
    if "error" not in result:
        current_app.logger.info(f"Product {product_id} removed from favorites for user {user_id}.")
        return jsonify({"message": "Product removed from favorites"}), 200

    current_app.logger.warning(
        f"Failed to remove product {product_id} from favorites for user {user_id}: {result['error']}")
    return jsonify(result), 400


@jwt_required()
def get_favorites():
    """
    Retrieves the user's list of favorite products.

    Returns:
        JSON: A JSON response containing the list of favorite products.
    """
    user_id = get_jwt_identity()
    current_app.logger.info(f"Fetching favorite products for user {user_id}.")

    favorites = get_user_favorites(user_id)
    current_app.logger.info(f"Favorite products for user {user_id} retrieved successfully.")

    return jsonify(favorites), 200


@jwt_required()
def sync_basket():
    """
    Synchronizes the user's basket with the provided basket data.

    Returns:
        JSON: A JSON response indicating the result of the synchronization.
    """
    user_id = get_jwt_identity()
    basket = request.get_json()
    current_app.logger.info(f"User {user_id} syncing basket.")

    result = sync_basket_service(user_id, basket)
    if "error" in result:
        current_app.logger.error(f"Error syncing basket for user {user_id}: {result['error']}")
    else:
        current_app.logger.info(f"Basket for user {user_id} synced successfully.")

    return jsonify(result), 200


@jwt_required()
def get_basket():
    """
    Retrieves the user's current basket.

    Returns:
        JSON: A JSON response containing the user's basket.
    """
    user_id = get_jwt_identity()
    current_app.logger.info(f"Fetching basket for user {user_id}.")

    basket = get_user_basket(user_id)
    current_app.logger.info(f"Basket for user {user_id} retrieved successfully.")

    return jsonify(basket), 200

@jwt_required()
def remove_from_basket():
    """
    Removes a product from the user's basket.

    Returns:
        JSON: A JSON response indicating the result of the removal.
    """
    user_id = get_jwt_identity()
    product_id = request.json.get("product_id")
    current_app.logger.info(f"User {user_id} attempting to remove product {product_id} from basket.")

    result = remove_from_basket_service(user_id, product_id)
    if "error" in result:
        current_app.logger.error(
            f"Error removing product {product_id} from basket for user {user_id}: {result['error']}")
    else:
        current_app.logger.info(f"Product {product_id} removed from basket for user {user_id}.")

    return jsonify(result), 200


@jwt_required()
def purchase_product():
    """
    Handles the purchase of a product by adding it to the user's purchased products and clearing the basket.

    Returns:
        JSON: A JSON response indicating success or failure.
    """
    user_id = get_jwt_identity()
    product_ids = request.json.get("purchased_products")
    current_app.logger.info(f"User {user_id} purchasing products {product_ids}.")

    if not isinstance(product_ids, list):
        current_app.logger.warning(f"Invalid data format for purchased products from user {user_id}.")
        return jsonify({"error": "Invalid data format"}), 400

    # Add products to purchased
    add_product_to_purchased(user_id, product_ids)
    current_app.logger.info(f"Products {product_ids} purchased successfully by user {user_id}.")

    # Clear the basket after purchase
    clear_user_basket(user_id)
    current_app.logger.info(f"Basket cleared for user {user_id} after purchase.")

    return jsonify({"message": "Product purchased successfully and basket cleared"}), 200


@jwt_required()
def get_purchased_products():
    """
    Retrieves the user's list of purchased products.
    Returns:
        JSON: A JSON response containing the list of purchased products.
    """
    user_id = get_jwt_identity()
    current_app.logger.info(f"Fetching purchased products for user {user_id}.")

    purchased_products = get_user_purchased_products(user_id)
    current_app.logger.info(f"Purchased products for user {user_id} retrieved successfully.")

    return jsonify(purchased_products), 200


@jwt_required()
def upload_avatar():
    """
    Handle avatar upload for the current logged-in user.

    Returns:
        JSON: A JSON response indicating success or failure.
    """
    user_id = get_jwt_identity()

    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    result = save_avatar(user_id, file)

    if 'error' in result:
        return jsonify(result), 400
    else:
        return jsonify(result), 200


def serve_avatar(filename):
    """
    Serve the avatar image from the avatar folder.
    """
    try:
        return send_from_directory(UPLOAD_FOLDER, filename)
    except FileNotFoundError:
        return send_from_directory(UPLOAD_FOLDER, 'user_default.png')
