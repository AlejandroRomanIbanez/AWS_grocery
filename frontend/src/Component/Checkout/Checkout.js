import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "./Checkout.css";
import axios from 'axios';
import emptyCart from '../Assets/emptycart.png';

export default function Checkout({ products, basket, setBasket }) {
  const [productQuantities, setProductQuantities] = useState({});
  const [address, setAddress] = useState({ street: '', city: '', postalCode: '' });
  const [payment, setPayment] = useState({ cardNumber: '', nameOnCard: '', expiration: '', cvv: '' });
  const [freeShippingAchieved, setFreeShippingAchieved] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    setProductQuantities(basket.reduce((acc, item) => {
      acc[item.product_id] = item.quantity;
      return acc;
    }, {}));
  }, [basket]);

  const handleQuantityChange = async (productId, delta) => {
    const newQuantities = { ...productQuantities };
    newQuantities[productId] = Math.max(0, (newQuantities[productId] || 0) + delta);

    if (newQuantities[productId] === 0) {
      handleRemoveFromCart(productId);
    } else {
      setProductQuantities(newQuantities);

      const updatedProductIndex = basket.findIndex(item => item.product_id === productId);
      if (updatedProductIndex === -1) return;

      const updatedProduct = { ...basket[updatedProductIndex] };
      updatedProduct.quantity = newQuantities[productId];

      const newBasket = [...basket];
      newBasket[updatedProductIndex] = updatedProduct;

      setBasket(newBasket);

      try {
        const token = localStorage.getItem('token');
        await axios.post(
          `${process.env.REACT_APP_BACKEND_SERVER}/api/me/basket`,
          newBasket,
          {
            headers: {
              Authorization: `Bearer ${token}`
            }
          }
        );
      } catch (error) {
        console.error('Failed to update basket:', error);
      }

      checkForFreeShipping(newBasket);
    }
  };

  const handleRemoveFromCart = async (productId) => {
    const newBasket = basket.filter(item => item.product_id !== productId);
    setBasket(newBasket);

    try {
      const token = localStorage.getItem('token');
      await axios.post(
        `${process.env.REACT_APP_BACKEND_SERVER}/api/me/basket`,
        newBasket,
        {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
      );
    } catch (error) {
      console.error('Failed to remove from basket:', error);
    }

    checkForFreeShipping(newBasket);
  };

  const getProductDetails = (productId) => {
    return products.find(product => product._id === productId) || {};
  };

  const handleInputChange = (e, setState) => {
    const { name, value } = e.target;
    setState(prevState => ({ ...prevState, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const allFieldsFilled = Object.values(address).every(field => field.trim() !== '') &&
      Object.values(payment).every(field => field.trim() !== '');

    if (allFieldsFilled) {
      try {
        // Perform the purchase
        await completePurchase();

        // Clear the basket
        setBasket([]);

        // Navigate to the home page
        navigate('/');
      } catch (error) {
        console.error('Checkout failed:', error);
      }
    } else {
      alert('Please fill all fields');
    }
  };

  const completePurchase = async () => {
    try {
      const token = localStorage.getItem('token');
      const purchasedProductIds = basket.map(item => item.product_id);
      console.log('Purchased Product IDs:', purchasedProductIds);

      await axios.post(
        `${process.env.REACT_APP_BACKEND_SERVER}/api/me/purchase`,
        { purchased_products: purchasedProductIds },
        {
          headers: {
            Authorization: `Bearer ${token}`
          }
        }
      );
    } catch (error) {
      console.error('Failed to complete purchase:', error);
      throw error;
    }
  };

  const calculateProductTotal = () => {
    return basket.reduce((acc, item) => {
      const product = getProductDetails(item.product_id);
      return acc + product.price * (productQuantities[item.product_id] || 0);
    }, 0).toFixed(2);
  };

  const calculateTotal = () => {
    const productTotal = calculateProductTotal();
    const shipmentCost = freeShippingAchieved || productTotal >= 20 ? 0 : 5;
    return (parseFloat(productTotal) + shipmentCost).toFixed(2);
  };

  const calculateShipmentCost = () => {
    const productTotal = calculateProductTotal();
    return freeShippingAchieved || productTotal >= 20 ? 0 : 5;
  };

  const checkForFreeShipping = (currentBasket) => {
    const productTotal = currentBasket.reduce((acc, item) => {
      const product = getProductDetails(item.product_id);
      return acc + product.price * item.quantity;
    }, 0);

    if (productTotal >= 20) {
      setFreeShippingAchieved(true);
    }
  };

  useEffect(() => {
    checkForFreeShipping(basket);
  }, [basket]);

  return (
    <section className="checkout-section">
      <div className="checkout-container">
        {basket.length > 0 ? (
          <>
            <div className="checkout-card">
              <div className="checkout-card-body">
                <h3 className="mb-5 pt-2 text-center fw-bold text-uppercase">
                  Your products
                </h3>

                <div className="basket-items-container">
                  {basket.map((item) => {
                    const product = getProductDetails(item.product_id);
                    return (
                      <div key={item.product_id} className="d-flex align-items-center mb-5">
                        <div className="checkout-card-item-container">
                          <div className="checkout-card-image-container">
                            <img
                              src={product.image_url}
                              className="checkout-card-image"
                              alt="Product"
                            />
                            <a href="#!" className="remove-icon" onClick={() => handleRemoveFromCart(item.product_id)}>
                              &times;
                            </a>
                          </div>
                          <div className="flex-grow-1 ms-3">
                            <h5 className="checkout-product-title">{product.name}</h5>
                            <div className="d-flex align-items-center">
                              <p className="checkout-price">{product.price}€</p>
                              <div className="checkout-quantity">
                                <button
                                  className="minus"
                                  onClick={() => handleQuantityChange(item.product_id, -1)}
                                >
                                  -
                                </button>
                                <input
                                  className="quantity-input"
                                  min={0}
                                  value={productQuantities[item.product_id] || 0}
                                  readOnly
                                  type="number"
                                />
                                <button
                                  className="plus"
                                  onClick={() => handleQuantityChange(item.product_id, 1)}
                                >
                                  +
                                </button>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>

                <hr
                  className="mb-4"
                  style={{
                    height: "2px",
                    backgroundColor: "#1266f1",
                    opacity: 1,
                  }}
                />

                <div className="shipment-container">
                  <h5 className="fw-bold mb-0">Shipment:</h5>
                  <h5 className="fw-bold mb-0">{calculateShipmentCost()}€</h5>
                </div>
                <div className="product-total-container">
                  <h5 className="fw-bold mb-0">Product Total:</h5>
                  <h5 className="fw-bold mb-0">
                    {calculateProductTotal()}€
                  </h5>
                </div>
                <div className="total-container">
                  <h5 className="fw-bold mb-0">Total:</h5>
                  <h5 className="fw-bold mb-0">
                    {calculateTotal()}€
                  </h5>
                </div>
                <div className="free-shipment-message">
                  Free shipment if your purchase is 20€ or more.
                </div>
              </div>
            </div>
            <div className="checkout-card payment-section">
              <div className="checkout-card-body">
                <form className="payment-form" onSubmit={handleSubmit}>
                  <h3 className="mb-5 pt-2 text-center fw-bold text-uppercase">
                    Shipment Address
                  </h3>
                  <input
                    className="shipment-input"
                    placeholder="Street Address"
                    type="text"
                    name="street"
                    value={address.street}
                    onChange={(e) => handleInputChange(e, setAddress)}
                  />
                  <input
                    className="shipment-input"
                    placeholder="City"
                    type="text"
                    name="city"
                    value={address.city}
                    onChange={(e) => handleInputChange(e, setAddress)}
                  />
                  <input
                    className="shipment-input"
                    placeholder="Postal Code"
                    type="text"
                    name="postalCode"
                    value={address.postalCode}
                    onChange={(e) => handleInputChange(e, setAddress)}
                  />
                  <hr
                    className="mb-4 mt-4"
                    style={{
                      height: "2px",
                      backgroundColor: "#1266f1",
                      opacity: 1,
                    }}
                  />
                  <h3 className="mb-5 pt-2 text-center fw-bold text-uppercase">
                    Payment
                  </h3>
                  <input
                    className="payment-input"
                    placeholder="Card number"
                    type="text"
                    name="cardNumber"
                    value={payment.cardNumber}
                    onChange={(e) => handleInputChange(e, setPayment)}
                  />
                  <input
                    className="payment-input"
                    placeholder="Name on card"
                    type="text"
                    name="nameOnCard"
                    value={payment.nameOnCard}
                    onChange={(e) => handleInputChange(e, setPayment)}
                  />
                  <div className="checkout-row">
                    <div className="checkout-col-md-6">
                      <input
                        className="payment-input"
                        placeholder="Expiration"
                        type="text"
                        name="expiration"
                        minLength="7"
                        maxLength="7"
                        value={payment.expiration}
                        onChange={(e) => handleInputChange(e, setPayment)}
                      />
                    </div>
                    <div className="checkout-col-md-6">
                      <input
                        className="payment-input"
                        placeholder="Cvv"
                        type="text"
                        name="cvv"
                        minLength="3"
                        maxLength="3"
                        value={payment.cvv}
                        onChange={(e) => handleInputChange(e, setPayment)}
                      />
                    </div>
                  </div>
                  <button className="btn-buy-now" type="submit">Buy now</button>
                </form>
              </div>
            </div>
          </>
        ) : (
          <div className="empty-cart-container">
            <img src={emptyCart} alt="Empty cart" className="empty-cart-image" />
            <h2>Your cart is empty</h2>
            <p>There are no products in your cart. Run to our store to get the best products at the best prices!</p>
          </div>
        )}
      </div>
    </section>
  );
}
