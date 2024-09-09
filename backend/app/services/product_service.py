from app import mongo
from bson import ObjectId
from typing import List, Dict
from ..helpers import serialize_object_id
from ..models.product_model import ReviewModel


def get_all_products() -> List[Dict]:
    """
    Retrieves all products from the database.

    Returns:
        List[Dict]: A list of dictionaries, each representing a product.
    """
    products_collection = mongo.grocery.products
    products = list(products_collection.find())
    return [serialize_object_id(product) for product in products]


def get_product_by_id(product_id: str) -> Dict:
    """
    Retrieves a product by its ID.

    Args:
        product_id (str): The ID of the product to retrieve.

    Returns:
        Dict: A dictionary representing the product if found, otherwise an empty dictionary.
    """
    products_collection = mongo.grocery.products
    product = products_collection.find_one({"_id": ObjectId(product_id)})
    if product:
        return serialize_object_id(product)
    return {}


def add_review_to_product(product_id: str, review_data: ReviewModel) -> Dict:
    """
    Adds a review to the specified product.

    Args:
        product_id (str): The ID of the product.
        review_data (ReviewModel): The review data.

    Returns:
        Dict: A dictionary containing the result of the review submission.
    """
    products_collection = mongo.grocery.products
    review_dict = review_data.dict()

    existing_review = products_collection.find_one(
        {"_id": ObjectId(product_id), "reviews.Author": review_dict['Author']}
    )

    if existing_review:
        return {"error": "User has already reviewed this product"}

    review_dict['Content'] = ''

    result = products_collection.update_one(
        {"_id": ObjectId(product_id)},
        {"$push": {"reviews": review_dict}}
    )

    if result.modified_count > 0:
        return {"message": "Review added successfully"}
    return {"error": "Product not found or review not added"}


def remove_review_from_product(product_id: str, author_name: str) -> Dict:
    products_collection = mongo.grocery.products

    result = products_collection.update_one(
        {"_id": ObjectId(product_id), "reviews.Author": author_name},
        {"$pull": {"reviews": {"Author": author_name}}}
    )

    if result.modified_count > 0:
        return {"message": "Review deleted successfully"}
    return {"error": "Product or review not found"}


def update_product_review(product_id: str, author_name: str, updated_data: Dict) -> Dict:
    products_collection = mongo.grocery.products

    update_fields = {
        "reviews.$.Rating": updated_data["Rating"],
        "reviews.$.Comment": updated_data["Comment"]
    }

    result = products_collection.update_one(
        {"_id": ObjectId(product_id), "reviews.Author": author_name},
        {"$set": update_fields}
    )

    if result.modified_count > 0:
        return {"message": "Review updated successfully"}
    return {"error": "Product or review not found"}
