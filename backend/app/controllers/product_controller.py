from flask import jsonify, request
from ..services.product_service import get_all_products, get_product_by_id, add_review_to_product, \
    remove_review_from_product, update_product_review
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy.exc import DataError
from flask import current_app
from ..services.user_service import get_user_info


def fetch_all_products():
    """
    Fetches all products from the database and returns them in JSON format.

    Returns:
        JSON: A JSON response containing a list of all products.
    """
    try:
        products = get_all_products()
        current_app.logger.info("Fetched all products.")
        return jsonify(products), 200
    except Exception as e:
        current_app.logger.error(f"Error fetching all products: {str(e)}")
        return jsonify({"error": "Unable to fetch products"}), 500


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
        product_id = int(product_id)
        current_app.logger.info(f"Fetching product with ID {product_id}.")
    except ValueError:
        current_app.logger.warning(f"Invalid product ID format: {product_id}")
        return jsonify({"error": "Invalid product ID"}), 400

    try:
        product = get_product_by_id(product_id)
        if product:
            current_app.logger.info(f"Product with ID {product_id} found.")
            return jsonify(product), 200
        current_app.logger.warning(f"Product with ID {product_id} not found.")
        return jsonify({'error': 'Product not found'}), 404
    except DataError as e:
        current_app.logger.error(f"Database error fetching product with ID {product_id}: {str(e)}")
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
            current_app.logger.warning(f"User {user_id} not found while trying to add a review.")
            return jsonify({"error": "User not found"}), 404

        review_data = request.json
        review_data['author'] = user_info.get('username', 'Anonymous')

        response = add_review_to_product(product_id, review_data)
        current_app.logger.info(f"User {user_id} added a review for product {product_id}.")
        return jsonify(response), 200
    except Exception as e:
        current_app.logger.error(f"Error adding review for product {product_id}: {str(e)}")
        return jsonify({"error": str(e)}), 400


@jwt_required()
def delete_review(product_id):
    try:
        data = request.get_json()
        author_name = data.get('author_name')
        response = remove_review_from_product(product_id, author_name)
        current_app.logger.info(f"Review by {author_name} for product {product_id} deleted.")
        return jsonify(response), 200
    except Exception as e:
        current_app.logger.error(f"Error deleting review for product {product_id}: {str(e)}")
        return jsonify({"error": str(e)}), 400


@jwt_required()
def update_review(product_id):
    try:
        data = request.json
        current_app.logger.info(f"Received data for update: {data}")

        author_name = data.get('author_name')

        if not author_name:
            current_app.logger.warning(f"Attempt to update review without author name for product {product_id}.")
            return jsonify({"error": "Author name is required"}), 400

        try:
            rating = int(data.get("rating"))
            if rating < 1 or rating > 5:
                current_app.logger.warning(f"Invalid rating value {rating} for product {product_id}.")
                return jsonify({"error": "Rating must be between 1 and 5"}), 400
        except (ValueError, TypeError):
            current_app.logger.warning(f"Invalid rating format for product {product_id}.")
            return jsonify({"error": "Invalid rating value"}), 400

        updated_data = {
            "rating": rating,
            "comment": data.get("comment")
        }

        if updated_data["comment"] is None:
            current_app.logger.warning(f"Missing comment while updating review for product {product_id}.")
            return jsonify({"error": "Comment is required"}), 400

        response = update_product_review(product_id, author_name, updated_data)
        current_app.logger.info(f"Review by {author_name} for product {product_id} updated.")
        return jsonify(response), 200
    except Exception as e:
        current_app.logger.error(f"Error updating review for product {product_id}: {str(e)}")
        return jsonify({"error": str(e)}), 400
