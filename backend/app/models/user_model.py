from pydantic import BaseModel, Field
from typing import List, Dict
from ..helpers import to_dict


class BasketItem(BaseModel):
    product_id: str
    quantity: int


class User(BaseModel):
    username: str = Field(..., min_length=1, max_length=50)
    email: str
    password: str = Field(..., min_length=6)
    fav_products: List[str] = Field(default_factory=list)
    basket: List[BasketItem] = Field(default_factory=list)
    purchased_products: List[str] = Field(default_factory=list)

    def to_dict(self) -> Dict:
        return to_dict(self)


class UserRegistration(BaseModel):
    username: str = Field(..., min_length=1, max_length=50)
    email: str
    password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
    email: str
    password: str = Field(..., min_length=6)
