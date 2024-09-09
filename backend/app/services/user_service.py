from app import mongo
from bson.objectid import ObjectId
from ..helpers import serialize_object_id
from typing import List, Dict


def get_user_info(user_id: str) -> dict:
    """
    Retrieves the user's information from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        dict: A dictionary containing the user's information.
    """
    users_collection = mongo.grocery.users
    user = users_collection.find_one({"_id": ObjectId(user_id)})
    if user:
        return {
            "username": user.get("username"),
        }
    return {}


def add_to_favorites(user_id: str, product_id: str) -> dict:
    """
    Adds a product to the user's list of favorite products in the database.

    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to add.

    Returns:
        dict: The raw result of the update operation.
    """
    users_collection = mongo.grocery.users
    result = users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$addToSet": {"fav_products": product_id}}
    )
    return result.raw_result


def remove_from_favorites(user_id: str, product_id: str) -> dict:
    """
    Removes a product from the user's list of favorite products in the database.

    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to remove.

    Returns:
        dict: The raw result of the update operation.
    """
    users_collection = mongo.grocery.users
    result = users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$pull": {"fav_products": product_id}}
    )
    return result.raw_result


def get_user_favorites(user_id: str) -> list:
    """
    Retrieves the user's list of favorite products from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        list: A list of dictionaries, each representing a favorite product.
    """
    users_collection = mongo.grocery.users
    products_collection = mongo.grocery.products
    user = users_collection.find_one({"_id": ObjectId(user_id)})
    if user and 'fav_products' in user:
        product_ids = [ObjectId(pid) for pid in user["fav_products"]]
        products = list(products_collection.find({"_id": {"$in": product_ids}}))
        return [serialize_object_id(product) for product in products]
    return []


def sync_basket_service(user_id: str, basket: List[Dict]) -> dict:
    """
    Synchronizes the user's basket with the provided basket data in the database.

    Args:
        user_id (str): The ID of the user.
        basket (List[Dict]): The basket data to synchronize.

    Returns:
        dict: A message indicating the result of the synchronization.
    """
    users_collection = mongo.grocery.users
    result = users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"basket": basket}}
    )
    if result.modified_count > 0:
        return {"message": "Basket successfully updated."}
    else:
        return {"message": "No changes made to the basket."}


def get_user_basket(user_id: str) -> List[Dict]:
    """
    Retrieves the user's current basket from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        List[Dict]: The user's basket.
    """
    users_collection = mongo.grocery.users
    user = users_collection.find_one({"_id": ObjectId(user_id)})

    if user and 'basket' in user:
        return user['basket']

    return []


def remove_from_basket_service(user_id: str, product_id: str) -> dict:
    """
    Removes a product from the user's basket in the database.

    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to remove.

    Returns:
        dict: A message indicating the result of the removal.
    """
    users_collection = mongo.grocery.users
    result = users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$pull": {"basket": {"product_id": product_id}}}
    )
    if result.modified_count > 0:
        return {"message": "Product removed from basket."}
    else:
        return {"message": "Product not found in the basket."}


def add_product_to_purchased(user_id: str, product_ids: List[str]) -> dict:
    """
    Adds a product to the user's set of purchased products.
    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to add.
    Returns:
        dict: The raw result of the update operation.
    """
    users_collection = mongo.grocery.users
    result = users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {"$addToSet": {"purchased_products": {"$each": product_ids}}}
    )
    return result.raw_result


def get_user_purchased_products(user_id: str) -> List[Dict]:
    """
    Retrieves the user's list of purchased products from the database.
    Args:
        user_id (str): The ID of the user.
    Returns:
        List[Dict]: A list of dictionaries representing purchased products.
    """
    users_collection = mongo.grocery.users
    user = users_collection.find_one({"_id": ObjectId(user_id)})
    if user and 'purchased_products' in user:
        id_products = list(user["purchased_products"])
        return id_products
    return []
