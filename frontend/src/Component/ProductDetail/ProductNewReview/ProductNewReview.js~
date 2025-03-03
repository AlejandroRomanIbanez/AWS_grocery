import React, { useState, useEffect } from 'react';
import './ProductNewReview.css';
import InteractiveRating from '../CustomRating/InteractiveRating';
import { toast, Toaster } from 'react-hot-toast';
import useUserInfo from '../../../hooks/useUserInfo';

const NewReview = ({ productId, reviews, onNewReview }) => {
  const { username, avatarUrl } = useUserInfo();
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');
  const [canReview, setCanReview] = useState(true);
  const maxCommentLength = 500;

  useEffect(() => {
    if (username) {
      const hasReviewed = reviews.some((review) => review.author === username);
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
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
        body: JSON.stringify({
          rating,
          comment,
        }),
      });

      const result = await response.json();
      if (response.ok) {
        toast.success('Review submitted successfully');
        setCanReview(false);
        onNewReview({ author: username, rating, comment });
      } else {
        toast.error(`${result.message || result.error}`);
      }
    } catch (error) {
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
            <div className="new-review-header">
              <div className="new-review-avatar">
                <img src={avatarUrl} alt="User Avatar" className="new-review-avatar-img" />
              </div>
              <h5>Add a comment</h5>
            </div>
            <div className="new-review-rating-stars">
              <InteractiveRating rating={rating} onRate={(newRating) => setRating(newRating)} />
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
              <span className={comment.length > maxCommentLength - 1 ? 'error' : ''}>
                {comment.length}/{maxCommentLength}
              </span>
            </div>
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
    </section>
  );
};

export default NewReview;
