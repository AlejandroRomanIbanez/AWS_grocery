from .. import db
from pydantic import BaseModel, Field


class BasketItem(db.Model):
    __tablename__ = 'basket_items'

    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'product_id': self.product_id,
            'quantity': self.quantity,
            'user_id': self.user_id
        }

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    fav_products = db.Column(db.String, default="")
    basket_items = db.relationship('BasketItem', backref='user', lazy=True, cascade="all, delete-orphan")
    purchased_products = db.Column(db.String, default="")
    avatar = db.Column(db.String(255), nullable=True)


class UserRegistration(BaseModel):
    username: str = Field(..., min_length=1, max_length=50)
    email: str
    password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
    email: str
    password: str = Field(..., min_length=6)
