from flask import Blueprint
from ..controllers.user_controller import add_favorite, get_favorites, remove_favorite, sync_basket, get_basket, \
    remove_from_basket, purchase_product, get_purchased_products, get_current_user_info, upload_avatar, serve_avatar, \
    get_all_users_info

user_bp = Blueprint('favorite', __name__, url_prefix='/api/me')

user_bp.route('/info', methods=['GET'])(get_current_user_info)
user_bp.route('/all-users', methods=['GET'])(get_all_users_info)
user_bp.route('/avatar', methods=['POST'])(upload_avatar)
user_bp.route('/avatar/<filename>', methods=['GET'])(serve_avatar)

user_bp.route('/favorites', methods=['POST'])(add_favorite)
user_bp.route('/favorites/remove', methods=['POST'])(remove_favorite)
user_bp.route('/favorites', methods=['GET'])(get_favorites)

user_bp.route('/basket', methods=['POST'])(sync_basket)
user_bp.route('/basket', methods=['GET'])(get_basket)
user_bp.route('/basket/remove', methods=['POST'])(remove_from_basket)

user_bp.route('/purchase', methods=['POST'])(purchase_product)
user_bp.route('/purchased-products', methods=['GET'])(get_purchased_products)
