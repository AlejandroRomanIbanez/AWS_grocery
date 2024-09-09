from .. import db
from bson.objectid import ObjectId
from ..helpers import serialize_object_id
from ..models.user_model import User, BasketItem
from typing import List, Dict


def get_user_info(user_id: str) -> dict:
    """
    Retrieves the user's information from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        dict: A dictionary containing the user's information.
    """
    user = User.query.get(user_id)
    if user:
        return {
            "username": user.username,
            "email": user.email,
            "fav_products": user.fav_products,
            "basket": [item.to_dict() for item in user.basket_items],
            "purchased_products": user.purchased_products
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
    user = User.query.get(user_id)
    if not user:
        return {"error": "User not found"}

    if product_id not in user.fav_products:
        user.fav_products.append(product_id)
        db.session.commit()
        return {"message": "Product added to favorites"}

    return {"message": "Product already in favorites"}


def remove_from_favorites(user_id: str, product_id: str) -> dict:
    """
    Removes a product from the user's list of favorite products in the database.

    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to remove.

    Returns:
        dict: The raw result of the update operation.
    """
    user = User.query.get(user_id)
    if not user:
        return {"error": "User not found"}

    if product_id in user.fav_products:
        user.fav_products.remove(product_id)
        db.session.commit()
        return {"message": "Product removed from favorites"}

    return {"error": "Product not found in favorites"}


def get_user_favorites(user_id: str) -> list:
    """
    Retrieves the user's list of favorite products from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        list: A list of dictionaries, each representing a favorite product.
    """
    user = User.query.get(user_id)
    if user:
        return user.fav_products
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
    user = User.query.get(user_id)
    if not user:
        return {"error": "User not found"}
    BasketItem.query.filter_by(user_id=user_id).delete()

    # Add new basket items
    for item in basket:
        new_item = BasketItem(user_id=user_id, product_id=item['product_id'], quantity=item['quantity'])
        db.session.add(new_item)

    db.session.commit()
    return {"message": "Basket successfully updated."}


def get_user_basket(user_id: str) -> List[Dict]:
    """
    Retrieves the user's current basket from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        List[Dict]: The user's basket.
    """
    basket_items = BasketItem.query.filter_by(user_id=user_id).all()

    return [{"product_id": item.product_id, "quantity": item.quantity} for item in basket_items]


def remove_from_basket_service(user_id: str, product_id: str) -> dict:
    """
    Removes a product from the user's basket in the database.

    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to remove.

    Returns:
        dict: A message indicating the result of the removal.
    """
    basket_item = BasketItem.query.filter_by(user_id=user_id, product_id=product_id).first()
    if basket_item:
        db.session.delete(basket_item)
        db.session.commit()
        return {"message": "Product removed from basket"}

    return {"error": "Product not found in basket"}


def add_product_to_purchased(user_id: str, product_ids: List[str]) -> dict:
    """
    Adds a product to the user's set of purchased products.
    Args:
        user_id (str): The ID of the user.
        product_id (str): The ID of the product to add.
    Returns:
        dict: The raw result of the update operation.
    """
    user = User.query.get(user_id)
    if not user:
        return {"error": "User not found"}

    user.purchased_products.extend(product_ids)
    user.purchased_products = list(set(user.purchased_products))
    db.session.commit()
    return {"message": "Products purchased successfully"}


def get_user_purchased_products(user_id: str) -> List[Dict]:
    """
    Retrieves the user's list of purchased products from the database.
    Args:
        user_id (str): The ID of the user.
    Returns:
        List[Dict]: A list of dictionaries representing purchased products.
    """
    user = User.query.get(user_id)
    if user:
        return user.purchased_products
    return []
