GroceryMate


Overview

GroceryMate is a comprehensive e-commerce platform offering the following features:

    User Authentication: Register and login functionality.
    Protected Routes: All the routes that need to be authenticated will redirect to /auth
    Product Search: Search for products, sort them by price, and filter by categories.
    Favorites: Add products to your favorites list.
    Shopping Basket: Add products to your basket and manage them.
    Check-out Process: Complete the checkout process with billing and shipping information, choose payment methods, and calculate the total price.

Features

    Register, Login, and Logout: Secure user authentication system.
    Product Search and Sorting: Search for products, and sort them by price or name in both ASC and DESC.
    Product Category and Price Range: Get the product by categories or range of price
    Favorites: Manage your favorite products.
    Shopping Basket: Add products to your basket, view, and modify the contents.
    Check-out Process:
        Billing and Shipping Information
        Payment Method Selection
        Total Price Calculation

Screenshots and videos


![imagen](https://github.com/user-attachments/assets/ea039195-67a2-4bf2-9613-2ee1e666231a)
![imagen](https://github.com/user-attachments/assets/a87e5c50-5a9e-45b8-ad16-2dbff41acd00)
![imagen](https://github.com/user-attachments/assets/589aae62-67ef-4496-bd3b-772cd32ca386)
![imagen](https://github.com/user-attachments/assets/2772b85e-81f7-446a-9296-4fdc2b652cb7)

https://github.com/user-attachments/assets/d1c5c8e4-5b16-486a-b709-4cf6e6cce6bc




Installation

Follow these steps to set up the application locally.
Create .env files in the backend and frontend, and follow the .env.examples to know what is required

Backend

Clone the Repository:

    bash
    cd backend

Create and Activate a Virtual Environment:

    bash

    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`

Install Requirements:

    bash
    
    pip install -r requirements.txt

Run the Application:

    bash
    
    python run.py

Frontend

Navigate to the Frontend Directory:

    bash

    cd ../frontend

Install Dependencies:

    bash
    
    npm install

Start the Application:

    bash
    
        npm start

Usage

    Register or Login:
        Open the application in your browser.
        Register a new account or login with your existing credentials.

    Search for Products:
        Use the search bar to find products.
        Sort products by price or filter by categories.

    Add to Favorites and Basket:
        Add products to your favorites list for quick access.
        Add products to your basket to proceed with the purchase.

    Checkout:
        Go to your basket and click on the checkout button.
        Fill in your billing and shipping information.
        Choose your preferred payment method.
        Review the total cost and confirm your purchase.