import os
from flask import current_app
from werkzeug.utils import secure_filename
from typing import List, Dict
from sqlalchemy import cast, ARRAY, Integer
from .. import db
from ..models.user_model import User, BasketItem
from ..models.product_model import Product


UPLOAD_FOLDER = os.path.join(os.getcwd(), 'avatar')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}


def get_all_users() -> list:
    """
    Retrieves all users from the database.

    Returns:
        list: A list of dictionaries containing each user's information.
    """
    users = User.query.all()
    user_list = []

    for user in users:
        user_list.append({
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "avatar": user.avatar if user.avatar else 'user_default.png',
        })

    current_app.logger.info(f"Retrieved {len(users)} users.")
    return user_list

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
        current_app.logger.info(f"Retrieved info for user {user.username} (ID: {user_id})")
        return {
            "username": user.username,
            "email": user.email,
            "fav_products": user.fav_products,
            "basket": [item.to_dict() for item in user.basket_items],
            "purchased_products": user.purchased_products,
            "avatar": user.avatar
        }
    current_app.logger.warning(f"User with ID {user_id} not found.")
    return {}


def add_to_favorites(user_id: int, product_id: int) -> dict:
    user = User.query.get(user_id)
    if not user:
        current_app.logger.error(f"User with ID {user_id} not found.")
        return {"error": "User not found"}

    if product_id not in user.fav_products:
        user.fav_products = cast(user.fav_products + [product_id], ARRAY(Integer))
        current_app.logger.info(f"Adding product {product_id} to user {user_id}'s favorites.")

        try:
            db.session.commit()
            current_app.logger.info(f"Product {product_id} added to favorites for user {user_id}.")
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f"Error adding product {product_id} to favorites for user {user_id}: {e}")
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
        current_app.logger.error(f"User with ID {user_id} not found.")
        return {"error": "User not found"}

    if product_id in user.fav_products:
        user.fav_products = cast([p for p in user.fav_products if p != product_id], ARRAY(Integer))
        current_app.logger.info(f"Removing product {product_id} from user {user_id}'s favorites.")

        try:
            db.session.commit()
            current_app.logger.info(f"Product {product_id} removed from favorites for user {user_id}.")
            return {"message": "Product removed from favorites"}
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f"Error removing product {product_id} from favorites for user {user_id}: {e}")
            return {"error": "Failed to save changes"}

    current_app.logger.warning(f"Product {product_id} not found in user {user_id}'s favorites.")
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
        current_app.logger.info(f"Fetched {len(favorite_products)} favorite products for user {user_id}.")
        return [product.to_dict() for product in favorite_products]
    current_app.logger.warning(f"No favorites found for user {user_id}.")
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
        current_app.logger.error(f"User with ID {user_id} not found.")
        return {"error": "User not found"}

    existing_items = BasketItem.query.filter_by(user_id=user_id).all()
    existing_product_ids = {item.product_id for item in existing_items}
    incoming_product_ids = {item['product_id'] for item in basket}

    items_to_delete = existing_product_ids - incoming_product_ids
    current_app.logger.info(f"Syncing basket for user {user_id}. Items to delete: {items_to_delete}")

    for product_id in items_to_delete:
        item_to_delete = BasketItem.query.filter_by(user_id=user_id, product_id=product_id).first()
        if item_to_delete:
            db.session.delete(item_to_delete)
            current_app.logger.info(f"Deleted item with product_id {product_id} for user {user_id}")

    for item in basket:
        product_id = item['product_id']
        existing_item = BasketItem.query.filter_by(user_id=user_id, product_id=product_id).first()

        if existing_item:
            existing_item.quantity = item['quantity']
            current_app.logger.info(f"Updated item {product_id} to quantity {item['quantity']} for user {user_id}")
        else:
            new_item = BasketItem(user_id=user_id, product_id=product_id, quantity=item['quantity'])
            db.session.add(new_item)
            current_app.logger.info(f"Added new item {product_id} with quantity {item['quantity']} for user {user_id}")

    try:
        db.session.commit()
        current_app.logger.info(f"Basket successfully synced for user {user_id}")
    except Exception as e:
        current_app.logger.error(f"Error syncing basket for user {user_id}: {e}")
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
        product = Product.query.get(item.product_id)
        if product:
            basket_with_details.append({
                "product_id": item.product_id,
                "quantity": item.quantity,
                "name": product.name,
                "price": product.price,
                "image_url": product.image_url,
            })
    current_app.logger.info(f"Fetched basket details for user {user_id}.")
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
        current_app.logger.info(f"Removed product {product_id} from user {user_id}'s basket.")
        return {"message": "Product removed from basket"}

    current_app.logger.warning(f"Product {product_id} not found in user {user_id}'s basket.")
    return {"error": "Product not found in basket"}


def add_product_to_purchased(user_id: int, product_ids: List[int]) -> dict:
    """
    Adds a product to the user's set of purchased products.
    Args:
        user_id (str): The ID of the user.
        product_ids (str): The ID of the product to add.
    Returns:
        dict: The raw result of the update operation.
    """
    user = User.query.get(user_id)
    if not user:
        current_app.logger.error(f"User with ID {user_id} not found.")
        return {"error": "User not found"}

    user.purchased_products.extend(product_ids)
    user.purchased_products = list(set(user.purchased_products))
    db.session.commit()
    current_app.logger.info(f"Added products {product_ids} to user {user_id}'s purchased products.")
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
        current_app.logger.info(f"Fetched purchased products for user {user_id}.")
        return user.purchased_products
    current_app.logger.warning(f"No purchased products found for user {user_id}.")
    return []


def clear_user_basket(user_id: int):
    """
    Clears the user's basket after a successful purchase.

    Args:
        user_id (int): The ID of the user.
    """
    current_app.logger.info(f"Attempting to clear basket for user {user_id}.")

    basket_items = BasketItem.query.filter_by(user_id=user_id).all()

    if not basket_items:
        current_app.logger.info(f"No items found in the basket for user {user_id}.")
        return {"message": "Basket is already empty"}

    try:
        for item in basket_items:
            current_app.logger.info(f"Removing item {item.product_id} from basket for user {user_id}.")
            db.session.delete(item)

        db.session.commit()
        current_app.logger.info(f"Successfully cleared basket for user {user_id}.")
        return {"message": "Basket cleared successfully"}

    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Error clearing basket for user {user_id}: {e}")
        return {"error": "Failed to clear basket"}


def allowed_file(filename):
    """
    Check if the file has one of the allowed extensions.
    """
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def save_avatar(user_id, file):
    """
    Save the user's avatar in the images folder and update the user's avatar in the database.

    Args:
        user_id (int): The ID of the user.
        file (FileStorage): The uploaded file.

    Returns:
        dict: A dictionary with the status of the operation.
    """
    if not allowed_file(file.filename):
        return {"error": "File type not allowed"}

    user = User.query.get(user_id)
    if not user:
        current_app.logger.error(f"User with ID {user_id} not found.")
        return {"error": "User not found"}

    # Secure the filename and save the file
    filename = secure_filename(f"user_{user_id}_{file.filename}")
    filepath = os.path.join(UPLOAD_FOLDER, filename)

    try:
        os.makedirs(UPLOAD_FOLDER, exist_ok=True)

        file.save(filepath)
        current_app.logger.info(f"File saved successfully at {filepath} for user {user_id}.")

        user.avatar = filename
        db.session.commit()
        current_app.logger.info(f"User {user_id}'s avatar updated to {filename}.")

        return {"message": "Avatar uploaded successfully", "avatar_url": filepath}
    except Exception as e:
        current_app.logger.error(f"Error saving avatar for user {user_id}: {e}")
        return {"error": "Failed to upload avatar"}