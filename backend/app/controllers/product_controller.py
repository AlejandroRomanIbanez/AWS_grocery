from flask import jsonify, request
from ..services.product_service import get_all_products, get_product_by_id, add_review_to_product, \
    remove_review_from_product, update_product_review
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy.exc import DataError

from ..services.user_service import get_user_info


def fetch_all_products():
    """
    Fetches all products from the database and returns them in JSON format.

    Returns:
        JSON: A JSON response containing a list of all products.
    """
    products = get_all_products()
    return jsonify(products)


def get_single_product(product_id):
    """
    Fetches a single product by its ID and returns it in JSON format.

    Args:
        product_id (str): The ID of the product to fetch.

    Returns:
        JSON: A JSON response containing the product if found,
              otherwise an error message with a 404 status code.
    """
    try:
        # Validate product_id is an integer
        product_id = int(product_id)
        print("""product_id""", product_id)
    except ValueError:
        return jsonify({"error": "Invalid product ID"}), 400

    try:
        product = get_product_by_id(product_id)
        if product:
            return jsonify(product)
        return jsonify({'error': 'Product not found'}), 404
    except DataError:
        return jsonify({"error": "Invalid product ID format"}), 400


@jwt_required()
def add_review(product_id):
    """
    Endpoint to add a review for a product.

    Args:
        product_id (str): The ID of the product.

    Returns:
        JSON: A JSON response indicating the result of the review submission.
    """
    try:
        # Get user ID from JWT
        user_id = get_jwt_identity()
        user_info = get_user_info(user_id)

        if not user_info:
            return jsonify({"error": "User not found"}), 404

        # Prepare review data with the author's name
        review_data = request.json
        review_data['author'] = user_info.get('username', 'Anonymous')

        response = add_review_to_product(product_id, review_data)
        return jsonify(response), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@jwt_required()
def delete_review(product_id):
    try:
        data = request.get_json()
        author_name = data.get('author_name')
        response = remove_review_from_product(product_id, author_name)
        return jsonify(response), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@jwt_required()
def update_review(product_id):
    try:
        data = request.json
        author_name = data.get('author_name')

        if not author_name:
            return jsonify({"error": "Author name is required"}), 400
        try:
            rating = int(data.get("rating"))
            if rating < 1 or rating > 5:
                return jsonify({"error": "rating must be between 1 and 5"}), 400
        except (ValueError, TypeError):
            return jsonify({"error": "Invalid rating value"}), 400

        updated_data = {
            "rating": rating,
            "comment": data.get("comment")
        }

        if updated_data["comment"] is None:
            return jsonify({"error": "Comment is required"}), 400

        response = update_product_review(product_id, author_name, updated_data)
        return jsonify(response), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
