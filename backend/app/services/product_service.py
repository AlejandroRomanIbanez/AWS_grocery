from .. import db
from bson import ObjectId
from typing import List, Dict
from ..helpers import serialize_object_id
from ..models.product_model import Review, Product


def get_all_products() -> List[Dict]:
    """
    Retrieves all products from the database.

    Returns:
        List[Dict]: A list of dictionaries, each representing a product.
    """
    products_collection = Product.query.all()
    return [product.to_dict() for product in products_collection]

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
        return product.to_dict()
    return {}


def add_review_to_product(product_id: str, review_data: Dict) -> Dict:
    """
    Adds a review to the specified product.

    Args:
        product_id (str): The ID of the product.
        review_data (Dict): The review data as a dictionary.

    Returns:
        Dict: A dictionary containing the result of the review submission.
    """
    product = Product.query.get(product_id)
    print(f"review_data: {review_data}")

    if not product:
        return {"error": "Product not found"}

    # Accessing dictionary keys directly instead of using object attributes
    existing_review = Review.query.filter_by(product_id=product_id, author=review_data["author"]).first()

    if existing_review:
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

    return {"message": "Review added successfully"}



def remove_review_from_product(product_id: str, author_name: str) -> Dict:
    review = Review.query.filter_by(product_id=product_id, author=author_name).first()

    if review:
        db.session.delete(review)
        db.session.commit()
        return {"message": "Review deleted successfully"}

    return {"error": "Review not found"}


def update_product_review(product_id: str, author_name: str, updated_data: Dict) -> Dict:
    review = Review.query.filter_by(product_id=product_id, author=author_name).first()

    if review:
        review.rating = updated_data["rating"]
        review.comment = updated_data["comment"]
        db.session.commit()
        return {"message": "Review updated successfully"}

    return {"error": "Review not found"}
