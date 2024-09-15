from .. import db
from flask import current_app
from typing import List, Dict
from ..models.product_model import Review, Product


def get_all_products() -> List[Dict]:
    """
    Retrieves all products from the database.

    Returns:
        List[Dict]: A list of dictionaries, each representing a product.
    """
    try:
        products_collection = Product.query.all()
        current_app.logger.debug(f"Products fetched: {products_collection}")
        if not products_collection:
            current_app.logger.error("No products fetched from the database.")
        return [product.to_dict() for product in products_collection]
    except Exception as e:
        current_app.logger.error(f"Error fetching products: {str(e)}")
        return []

def get_product_by_id(product_id: int) -> Dict:
    """
    Retrieves a product by its ID.

    Args:
        product_id (str): The ID of the product to retrieve.

    Returns:
        Dict: A dictionary representing the product if found, otherwise an empty dictionary.
    """
    product = Product.query.get(product_id)
    if product:
        current_app.logger.info(f"Product with ID {product_id} found.")
        return product.to_dict()
    current_app.logger.warning(f"Product with ID {product_id} not found.")
    return {}


def add_review_to_product(product_id: int, review_data: Dict) -> Dict:
    """
    Adds a review to the specified product.

    Args:
        product_id (str): The ID of the product.
        review_data (Dict): The review data as a dictionary.

    Returns:
        Dict: A dictionary containing the result of the review submission.
    """
    product = Product.query.get(product_id)
    current_app.logger.debug(f"Review data received: {review_data}")

    if not product:
        current_app.logger.error(f"Product with ID {product_id} not found.")
        return {"error": "Product not found"}

    existing_review = Review.query.filter_by(product_id=product_id, author=review_data["author"]).first()

    if existing_review:
        current_app.logger.warning(f"User {review_data['author']} has already reviewed product {product_id}.")
        return {"error": "User has already reviewed this product"}

    # Manually creating the review based on the dictionary data
    new_review = Review(
        product_id=product_id,
        author=review_data["author"],
        rating=review_data["rating"],
        comment=review_data.get("comment", "")
    )

    db.session.add(new_review)
    db.session.commit()

    current_app.logger.info(f"New review added for product {product_id} by {review_data['author']}.")
    return {"message": "Review added successfully"}


def remove_review_from_product(product_id: int, author_name: str) -> Dict:
    review = Review.query.filter_by(product_id=product_id, author=author_name).first()

    if review:
        db.session.delete(review)
        db.session.commit()
        current_app.logger.info(f"Review by {author_name} for product {product_id} deleted successfully.")
        return {"message": "Review deleted successfully"}

    current_app.logger.warning(f"Review by {author_name} for product {product_id} not found.")
    return {"error": "Review not found"}


def update_product_review(product_id: int, author_name: str, updated_data: Dict) -> Dict:
    review = Review.query.filter_by(product_id=product_id, author=author_name).first()

    if review:
        review.rating = updated_data["rating"]
        review.comment = updated_data["comment"]
        db.session.commit()
        current_app.logger.info(f"Updated review added for product {product_id} by {review.author}.")
        return {"message": "Review updated successfully"}

    current_app.logger.warning(f"Review by {author_name} for product {product_id} not found.")
    return {"error": "Review not found"}
