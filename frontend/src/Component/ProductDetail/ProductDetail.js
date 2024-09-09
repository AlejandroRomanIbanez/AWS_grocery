import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import CustomRating from './CustomRating/CustomRating'; // Custom rating component
import ProductComments from './ProductComments/ProductComments';
import NewReview from './ProductNewReview/ProductNewReview';
import './ProductDetail.css';
import SkeletonDetail from '../Skeleton/SkeletonDetail';

const ProductDetail = () => {
  const { productId } = useParams();
  const [productDetailItem, setProductDetailItem] = useState(null);
  const [userPurchasedProducts, setUserPurchasedProducts] = useState([]);
  const [hasReviewed, setHasReviewed] = useState(false);
  const [canLeaveReview, setCanLeaveReview] = useState(false);

  useEffect(() => {
    const fetchProductDetail = async () => {
      try {
        const response = await axios.get(`${process.env.REACT_APP_BACKEND_SERVER}/api/products/${productId}`);
        setProductDetailItem(response.data);
      } catch (error) {
        console.error("Failed to fetch product details:", error);
      }
    };

    const fetchUserPurchasedProducts = async () => {
      try {
        const token = localStorage.getItem('token');
        if (token) {
          const response = await axios.get(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/purchased-products`, {
            headers: {
              Authorization: `Bearer ${token}`
            }
          });
          setUserPurchasedProducts(response.data || []);
        }
      } catch (error) {
        console.error("Failed to fetch purchased products:", error);
      }
    };

    fetchProductDetail();
    fetchUserPurchasedProducts();
  }, [productId]);

  useEffect(() => {
    if (productDetailItem) {
      const purchased = userPurchasedProducts.includes(productId);
      setCanLeaveReview(purchased);
      setHasReviewed(purchased && productDetailItem.reviews.some(review => review.Author === localStorage.getItem('username')));
    }
  }, [userPurchasedProducts, productDetailItem, productId]);

  const handleNewReview = (newReview) => {
    const modifiedReview = {
      ...newReview,
      Comment: ""
  };
    setProductDetailItem((prevItem) => ({
      ...prevItem,
      reviews: [...prevItem.reviews, modifiedReview],
    }));
    setCanLeaveReview(false);
    setHasReviewed(true);
  };

  const calculateAverageRating = (reviews) => {
    if (!reviews || reviews.length === 0) return 0;
    const totalRating = reviews.reduce((acc, review) => acc + review.Rating, 0);
    return (totalRating / reviews.length).toFixed(1);
  };

  const handleDeleteReview = async (authorName) => {
    try {
      await axios.delete(`${process.env.REACT_APP_BACKEND_SERVER}/api/products/${productId}/remove-review`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        data: { author_name: authorName }
      });
      setProductDetailItem(prevItem => ({
        ...prevItem,
        reviews: prevItem.reviews.filter(
          review => review.Author !== authorName
        )
      }));
      setHasReviewed(false);
    } catch (error) {
      console.error("Error deleting review:", error);
    }
  };

  const handleEditReview = async (authorName, newRating, newComment) => {
    try {
      await axios.put(`${process.env.REACT_APP_BACKEND_SERVER}/api/products/${productId}/update-review`, {
        author_name: authorName,
        Rating: newRating,
        Comment: newComment
      }, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });
      setProductDetailItem(prevItem => ({
        ...prevItem,
        reviews: prevItem.reviews.map(review =>
          review.Author === authorName
            ? { ...review, Rating: newRating, Comment: newComment }
            : review
        )
      }));
    } catch (error) {
      console.error("Error updating review:", error);
    }
  };

  if (!productDetailItem) {
    return <SkeletonDetail />;
  }

  const averageRating = calculateAverageRating(productDetailItem.reviews);
  console.log("Average Rating:", averageRating);

  return (
    <section className="productDetailContainer">
      <div className="imageGalleryContainer">
        <img src={productDetailItem.image_url} alt="Product" className="productImage" />
      </div>
      <div className="descriptionContainer">
        <h2>{productDetailItem.name}</h2>
        <div className="ratingContainer">
          <CustomRating rating={parseFloat(averageRating)} />
          <p className="reviews">({productDetailItem.reviews?.length || 0})</p>
        </div>
        <p className="category">Category: <span>{productDetailItem.category}</span></p>
        <p className="price">{productDetailItem.price}€</p>
      </div>
      {canLeaveReview ? (
        hasReviewed ? (
          <div className="reviewRestriction">
            <p>You have already reviewed this product.</p>
          </div>
        ) : (
          <NewReview 
            productId={productId} 
            reviews={productDetailItem.reviews || []}  
            onNewReview={handleNewReview}
          />
        )
      ) : (
        <div className="reviewRestriction">
          <p>You need to buy this product to tell us your opinion!</p>
        </div>
      )}
      <ProductComments 
        reviews={productDetailItem.reviews || []} 
        onDelete={handleDeleteReview} 
        onEdit={handleEditReview} 
      />
    </section>
  );
};

export default ProductDetail;
