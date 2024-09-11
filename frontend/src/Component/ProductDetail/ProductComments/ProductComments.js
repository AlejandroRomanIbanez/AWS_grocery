import React, { useState, useEffect, useRef } from 'react';
import CustomRating from '../CustomRating/CustomRating';
import './ProductComments.css';
import useUserInfo from '../../../hooks/useUserInfo'; // Import the custom hook

const ProductComments = ({ reviews, onDelete, onEdit }) => {
  const { username, getAvatarUrl, fetchUserInfo } = useUserInfo(); // Add fetchUserInfo to refetch when necessary
  const [reRenderKey, setReRenderKey] = useState(0); // State to trigger re-render
  const reversedReviews = [...reviews].reverse();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentDropdown, setCurrentDropdown] = useState(null);
  const [currentReview, setCurrentReview] = useState(null);
  const [updatedRating, setUpdatedRating] = useState(0);
  const [updatedComment, setUpdatedComment] = useState('');
  const dropdownRef = useRef(null);

  useEffect(() => {
    fetchUserInfo(); // Re-fetch user info when the component mounts
  }, [reRenderKey, fetchUserInfo]); // Add reRenderKey to force update when avatar changes

  const toggleDropdown = (index) => {
    setCurrentDropdown(currentDropdown === index ? null : index);
  };

  const handleDelete = (authorName) => {
    if (window.confirm('Are you sure you want to delete this review?')) {
      onDelete(authorName);
      setCurrentDropdown(null);
    }
  };

  const handleEdit = (review) => {
    setCurrentReview(review);
    setUpdatedRating(parseInt(review.rating));
    setUpdatedComment(review.comment);
    setIsModalOpen(true);
    setCurrentDropdown(null);
  };

  const handleModalClose = () => {
    setIsModalOpen(false);
    setCurrentReview(null);
    fetchUserInfo(); // Re-fetch user info when modal closes
    setReRenderKey((prev) => prev + 1); // Trigger a re-render
  };

  const handleSubmit = () => {
    onEdit(currentReview.author, parseInt(updatedRating), updatedComment);
    handleModalClose();
  };

  return (
    <section className="product-comments">
      <div className="comments-container">
        {reversedReviews.map((review, index) => (
          <div className="comment" key={`${index}-${reRenderKey}`}> {/* Key includes reRenderKey to force re-render */}
            <div className="comment-body">
              <div className="comment-header">
                {/* Display avatar and username */}
                <div className="comment-author">
                  <img
                    src={getAvatarUrl(review.author)} // Use helper to get avatar
                    alt="User Avatar"
                    className="comment-avatar"
                  />
                  <h5 className="comment-username"><strong>{review.author}</strong></h5>
                </div>
                {review.author === username && (
                  <div className="menu-icon" onClick={() => toggleDropdown(index)}>...</div>
                )}
                {currentDropdown === index && (
                  <div className="dropdown-menu" ref={dropdownRef}>
                    <button onClick={() => handleEdit(review)}>Edit</button>
                    <button onClick={() => handleDelete(review.author)}>Delete</button>
                  </div>
                )}
              </div>
              <p>{review.comment}</p>
              <div className="comment-footer">
                <div className="comment-actions">
                  <div className="rating">
                    <CustomRating rating={review.rating} />
                    <span className="small">({parseInt(review.rating.toFixed(1))})</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {isModalOpen && (
        <div className="modal-overlay">
          <div className="modal">
            <h2>Edit Review</h2>
            <label>
              Rating:
              <input
                type="number"
                value={updatedRating}
                onChange={(e) => setUpdatedRating(e.target.value)}
                min={1}
                max={5}
                step={1}
              />
            </label>
            <label>
              Comment:
              <textarea
                value={updatedComment}
                onChange={(e) => setUpdatedComment(e.target.value)}
              />
            </label>
            <div className="modal-buttons">
              <button onClick={handleSubmit}>Save Changes</button>
              <button onClick={handleModalClose}>Cancel</button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
};

export default ProductComments;
