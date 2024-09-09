from pydantic import BaseModel, Field, HttpUrl
from typing import Optional, Dict, List
from enum import Enum
from ..helpers import to_dict


class ReviewModel(BaseModel):
    Author: str = Field(..., description="Name of the reviewer")
    Rating: float = Field(..., ge=1, le=5, description="Rating of the product, between 1 and 5")
    Comment: str = Field(..., max_length=500, description="Review comment, up to 500 characters")

class ProductCategory(Enum):
    FRUITS = "Fruits"
    VEGETABLES = "Vegetables"
    DAIRY = "Dairy"
    MEAT = "Meat"
    BAKERY = "Bakery"
    BEVERAGES = "Beverages"
    SNACKS = "Snacks"
    CANNED_GOODS = "Canned Goods"
    FROZEN_FOODS = "Frozen Foods"
    HOUSEHOLD = "Household"
    PERSONAL_CARE = "Personal Care"
    CLEANING_SUPPLIES = "Cleaning Supplies"
    PANTRY = "Pantry"
    ALCOHOL = "Alcohol"


class ProductModel(BaseModel):
    name: str = Field(..., description="Name of the product")
    description: str = Field(..., description="Description of the product")
    price: float = Field(..., gt=0, description="Price of the product, must be greater than 0")
    category: ProductCategory = Field(..., description="Category of the product")
    image_url: HttpUrl = Field(..., description="URL of the product image")
    is_alcohol: bool = Field(default=False, description="Indicates if the product is alcoholic")
    reviews: Optional[List[ReviewModel]] = Field(default=None, description="List of reviews for the product")

    def to_dict(self) -> Dict:
        return to_dict(self)
