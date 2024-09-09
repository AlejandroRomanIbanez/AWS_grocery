from flask import jsonify, request
from flask_jwt_extended import get_jwt_identity, jwt_required
from app.services.user_service import add_to_favorites, get_user_favorites, remove_from_favorites, sync_basket_service, \
    get_user_basket, remove_from_basket_service, add_product_to_purchased, get_user_purchased_products, get_user_info


@jwt_required()
def get_current_user_info():
    """
    Retrieves the current user's information.

    Returns:
        JSON: A JSON response containing the user's information.
    """
    user_id = get_jwt_identity()
    user_info = get_user_info(user_id)
    if user_info:
        return jsonify(user_info), 200
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

    result = add_to_favorites(user_id, product_id)
    if result['nModified'] == 1:
        return jsonify({"message": "Product added to favorites"}), 201
    return jsonify({"error": "Product not added"}), 400


@jwt_required()
def remove_favorite():
    """
    Removes a product from the user's list of favorite products.

    Returns:
        JSON: A JSON response indicating success or failure.
    """
    user_id = get_jwt_identity()
    product_id = request.json.get("product_id")
    result = remove_from_favorites(user_id, product_id)
    if result['nModified'] == 1:
        return jsonify({"message": "Product removed from favorites"}), 200
    return jsonify({"error": "Product not removed"}), 400


@jwt_required()
def get_favorites():
    """
    Retrieves the user's list of favorite products.

    Returns:
        JSON: A JSON response containing the list of favorite products.
    """
    user_id = get_jwt_identity()
    favorites = get_user_favorites(user_id)
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

    result = sync_basket_service(user_id, basket)
    return jsonify(result), 200


@jwt_required()
def get_basket():
    """
    Retrieves the user's current basket.

    Returns:
        JSON: A JSON response containing the user's basket.
    """
    user_id = get_jwt_identity()
    basket = get_user_basket(user_id)
    return jsonify([item for item in basket]), 200


@jwt_required()
def remove_from_basket():
    """
    Removes a product from the user's basket.

    Returns:
        JSON: A JSON response indicating the result of the removal.
    """
    user_id = get_jwt_identity()
    product_id = request.json.get("product_id")

    result = remove_from_basket_service(user_id, product_id)
    return jsonify(result), 200


@jwt_required()
def purchase_product():
    """
    Handles the purchase of a product by adding it to the user's purchased products.
    Returns:
        JSON: A JSON response indicating success or failure.
    """
    user_id = get_jwt_identity()
    product_ids = request.json.get("purchased_products")

    if not isinstance(product_ids, list):
        return jsonify({"error": "Invalid data format"}), 400

    add_product_to_purchased(user_id, product_ids)
    return jsonify({"message": "Product purchased successfully"}), 200


@jwt_required()
def get_purchased_products():
    """
    Retrieves the user's list of purchased products.
    Returns:
        JSON: A JSON response containing the list of purchased products.
    """
    user_id = get_jwt_identity()
    purchased_products = get_user_purchased_products(user_id)
    return jsonify(purchased_products), 200
