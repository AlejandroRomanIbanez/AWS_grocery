from .. import db
from bson.objectid import ObjectId
from ..helpers import serialize_object_id
from ..models.user_model import User, BasketItem
from ..models.product_model import Product
from sqlalchemy import cast, ARRAY, Integer
from typing import List, Dict


def get_user_info(user_id: int) -> dict:
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


def add_to_favorites(user_id: int, product_id: int) -> dict:
    user = User.query.get(user_id)
    if not user:
        return {"error": "User not found"}

    if product_id not in user.fav_products:
        user.fav_products = cast(user.fav_products + [product_id], ARRAY(Integer))
        print(f"user.fav_products before commit: {user.fav_products}")

        try:
            db.session.commit()
            print("Commit successful")
        except Exception as e:
            db.session.rollback()
            print(f"Error committing changes: {e}")
            return {"error": "Failed to save changes"}

        return {"message": "Product added to favorites"}

    return {"message": "Product already in favorites"}


def remove_from_favorites(user_id: int, product_id: int) -> dict:
    """
    Removes a product from the user's list of favorite products in the database.

    Args:
        user_id (int): The ID of the user.
        product_id (int): The ID of the product to remove.

    Returns:
        dict: The raw result of the update operation.
    """
    user = User.query.get(user_id)
    if not user:
        return {"error": "User not found"}

    if product_id in user.fav_products:
        # Cast the updated list to ARRAY(Integer) before committing
        user.fav_products = cast([p for p in user.fav_products if p != product_id], ARRAY(Integer))
        print(f"user.fav_products before commit: {user.fav_products}")

        try:
            db.session.commit()
            print("Commit successful")
            return {"message": "Product removed from favorites"}
        except Exception as e:
            db.session.rollback()
            print(f"Error committing changes: {e}")
            return {"error": "Failed to save changes"}

    return {"error": "Product not found in favorites"}


def get_user_favorites(user_id: int) -> list:
    """
    Retrieves the user's list of favorite products from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        list: A list of dictionaries, each representing a favorite product.
    """
    user = User.query.get(user_id)
    if user:
        favorite_products = Product.query.filter(Product.id.in_(user.fav_products)).all()
        return [product.to_dict() for product in favorite_products]
    return []


def sync_basket_service(user_id: int, basket: List[Dict]) -> dict:
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

    existing_items = BasketItem.query.filter_by(user_id=user_id).all()
    existing_product_ids = {item.product_id for item in existing_items}
    incoming_product_ids = {item['product_id'] for item in basket}

    items_to_delete = existing_product_ids - incoming_product_ids

    for product_id in items_to_delete:
        item_to_delete = BasketItem.query.filter_by(user_id=user_id, product_id=product_id).first()
        if item_to_delete:
            print(f"Deleting item with product_id: {product_id}")
            db.session.delete(item_to_delete)

    for item in basket:
        product_id = item['product_id']
        existing_item = BasketItem.query.filter_by(user_id=user_id, product_id=product_id).first()

        if existing_item:
            print(f"Updating item with product_id: {product_id} to quantity: {item['quantity']}")
            existing_item.quantity = item['quantity']
        else:
            print(f"Adding new item with product_id: {product_id} and quantity: {item['quantity']}")
            new_item = BasketItem(user_id=user_id, product_id=product_id, quantity=item['quantity'])
            db.session.add(new_item)

    try:
        # Commit the changes
        db.session.commit()
        print("Basket successfully updated")
    except Exception as e:
        print(f"Error committing changes to the database: {e}")
        return {"error": "Failed to update basket"}

    return {"message": "Basket successfully updated."}


def get_user_basket(user_id: int) -> List[Dict]:
    """
    Retrieves the user's current basket from the database.

    Args:
        user_id (str): The ID of the user.

    Returns:
        List[Dict]: The user's basket.
    """
    basket_items = BasketItem.query.filter_by(user_id=user_id).all()

    basket_with_details = []
    for item in basket_items:
        # Fetch product details using the product_id
        product = Product.query.get(item.product_id)
        if product:
            basket_with_details.append({
                "product_id": item.product_id,
                "quantity": item.quantity,
                "name": product.name,
                "price": product.price,
                "image_url": product.image_url,
            })
    return basket_with_details


def remove_from_basket_service(user_id: int, product_id: int) -> dict:
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


def add_product_to_purchased(user_id: int, product_ids: List[int]) -> dict:
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


def get_user_purchased_products(user_id: int) -> List[Dict]:
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
