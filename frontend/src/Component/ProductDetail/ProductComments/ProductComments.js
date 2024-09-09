import React, { useState, useEffect, useRef } from 'react';
import CustomRating from '../CustomRating/CustomRating';
import './ProductComments.css';

const ProductComments = ({ reviews, onDelete, onEdit }) => {
  const reversedReviews = [...reviews].reverse();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentDropdown, setCurrentDropdown] = useState(null); // Track which dropdown is open
  const [currentReview, setCurrentReview] = useState(null);
  const [updatedRating, setUpdatedRating] = useState(0);
  const [updatedComment, setUpdatedComment] = useState('');
  const [username, setUsername] = useState('');
  const dropdownRef = useRef(null); // Reference to the dropdown

  useEffect(() => {
    // Fetch the current user's username from the backend
    const fetchUserInfo = async () => {
      const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/info`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsername(data.username);
      } else {
        console.error('Failed to fetch user info');
      }
    };

    fetchUserInfo();
  }, []);

  useEffect(() => {
    // Close the dropdown if clicked outside
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setCurrentDropdown(null);
      }
    };
    
    document.addEventListener('mousedown', handleClickOutside);
    
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [dropdownRef]);

  const toggleDropdown = (index) => {
    setCurrentDropdown(currentDropdown === index ? null : index);
  };

  const handleDelete = (authorName) => {
    if (window.confirm('Are you sure you want to delete this review?')) {
      onDelete(authorName);
      setCurrentDropdown(null); // Close the dropdown after action
    }
  };

  const handleEdit = (review) => {
    setCurrentReview(review);
    setUpdatedRating(parseInt(review.Rating));
    setUpdatedComment(review.Comment);
    setIsModalOpen(true);
    setCurrentDropdown(null); // Close the dropdown after action
  };

  const handleModalClose = () => {
    setIsModalOpen(false);
    setCurrentReview(null);
  };

  const handleSubmit = () => {
    onEdit(currentReview.Author, parseInt(updatedRating), updatedComment);
    handleModalClose();
  };

  return (
    <section className="product-comments">
      <div className="comments-container">
        {reversedReviews.length > 0 ? (
          reversedReviews.map((review, index) => (
            <div className="comment" key={index}>
              <div className="comment-body">
                <div className="comment-header">
                  <h5><strong>{review.Author}</strong></h5>
                  {review.Author === username && (
                    <div className="menu-icon" onClick={() => toggleDropdown(index)}>...</div>
                  )}
                  {currentDropdown === index && (
                    <div className="dropdown-menu" ref={dropdownRef}>
                      <button onClick={() => handleEdit(review)}>Edit</button>
                      <button onClick={() => handleDelete(review.Author)}>Delete</button>
                    </div>
                  )}
                </div>
                <p>{review.Comment}</p>
                <div className="comment-footer">
                  <div className="comment-actions">
                    <div className="rating">
                      <CustomRating rating={review.Rating} />
                      <span className="small">({parseInt(review.Rating.toFixed(1))})</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))
        ) : (
          <p>No reviews available.</p>
        )}
      </div>

      {/* Edit Review Modal */}
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
