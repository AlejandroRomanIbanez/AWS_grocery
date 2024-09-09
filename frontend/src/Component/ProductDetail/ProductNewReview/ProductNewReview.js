import React, { useEffect, useState } from 'react';
import './ProductNewReview.css';
import InteractiveRating from '../CustomRating/InteractiveRating';
import { toast, Toaster } from 'react-hot-toast';

const NewReview = ({ productId, reviews, onNewReview }) => {
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');
  const [canReview, setCanReview] = useState(true);
  const [username, setUsername] = useState('');
  const maxCommentLength = 500;

  useEffect(() => {
    // Fetch the current user's username from the backend
    const fetchUserInfo = async () => {
      try {
        const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/info`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('token')}`,
          },
        });

        if (response.ok) {
          const data = await response.json();
          setUsername(data.username);
          localStorage.setItem('username', data.username); // Store username in local storage
        } else {
          toast.error('Failed to fetch user info');
        }
      } catch (error) {
        console.error('Error fetching user info:', error);
        toast.error('Error fetching user info. Please try again later.');
      }
    };

    fetchUserInfo();
  }, []);

  useEffect(() => {
    // Check if the user has already reviewed this product
    if (username) {
      const hasReviewed = reviews.some(review => review.Author === username);
      setCanReview(!hasReviewed);
    }
  }, [reviews, username]);

  const handleCommentChange = (e) => {
    const { value } = e.target;
    if (value.length <= maxCommentLength) {
      setComment(value);
    }
  };

  const handleSubmit = async () => {
    if (comment.length > maxCommentLength) {
      toast.error('Your comment exceeds the 500 character limit.');
      return;
    }

    try {
      const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/api/products/${productId}/add-review`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
        },
        body: JSON.stringify({
          Rating: rating,
          Comment: "",  // This is the subtle bug; you might use "comment" instead to fix it.
        }),
      });
  
      const result = await response.json();
      if (response.ok) {
        toast.success('Review submitted successfully');
        setCanReview(false);
        // Trigger the callback to update the parent component's state
        onNewReview({ Author: username, Rating: rating, Comment: comment });
      } else {
        toast.error(`${result.message || result.error}`);
      }
    } catch (error) {
      console.error('Error submitting review:', error);
      toast.error('An unexpected error occurred. Please try again later.');
    }
  };

  if (!canReview) {
    return <p>You have already reviewed this product.</p>;
  }

  return (
    <section className="new-review-section">
      <Toaster />
      <div className="new-review-container">
        <div className="new-review-card">
          <div className="new-review-card-body">
            <div className="new-review-d-flex">
              <div className="new-review-w-100">
                <h5>Add a comment</h5>
                <div className="new-review-rating-stars">
                  <InteractiveRating
                    rating={rating}
                    onRate={(newRating) => setRating(newRating)}
                  />
                </div>
                <textarea
                  className={`new-review-form-control ${comment.length > maxCommentLength ? 'error' : ''}`}
                  rows="4"
                  placeholder="What is your view?"
                  value={comment}
                  onChange={handleCommentChange}
                  maxLength={maxCommentLength}
                ></textarea>
                <div className="new-review-char-counter">
                  <span className={comment.length > maxCommentLength -1 ? 'error' : ''}>
                    {comment.length}/{maxCommentLength}
                  </span>
                </div>
                {comment.length > maxCommentLength - 1 && (
                  <p className="error-message">
                    You cannot tell us more about this product.
                  </p>
                )}
                <div className="new-review-btn-container new-review-mt-3">
                  <button className="new-review-btn new-review-btn-cancel">Cancel</button>
                  <button
                    className="new-review-btn new-review-btn-send"
                    onClick={handleSubmit}
                    disabled={comment.length > maxCommentLength}
                  >
                    Send <i className="fas fa-long-arrow-alt-right new-review-ms-1"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default NewReview;
