from flask import Blueprint
from app.controllers.product_controller import fetch_all_products, get_single_product, add_review, delete_review, update_review

product_bp = Blueprint('product', __name__, url_prefix='/api/products')

product_bp.route('/all_products', methods=['GET'])(fetch_all_products)
product_bp.route('/<product_id>', methods=['GET'])(get_single_product)

product_bp.route('/<product_id>/add-review', methods=['POST'])(add_review)
product_bp.route('/<product_id>/remove-review', methods=['DELETE'])(delete_review)
product_bp.route('/<product_id>/update-review', methods=['PUT'])(update_review)
