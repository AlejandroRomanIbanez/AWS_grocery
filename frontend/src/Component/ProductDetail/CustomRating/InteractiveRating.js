import React, { useState } from 'react';
import './InteractiveRating.css';

const InteractiveRating = ({ initialRating = 0, onRate }) => {
  const [rating, setRating] = useState(initialRating);
  const [hoveredRating, setHoveredRating] = useState(0);

  const handleMouseEnter = (index) => {
    setHoveredRating(index);
  };

  const handleMouseLeave = () => {
    setHoveredRating(0);
  };

  const handleClick = (index) => {
    setRating(index);
    if (onRate) {
      onRate(index);
    }
  };

  return (
    <div className="interactive-rating">
      {[...Array(5)].map((_, index) => (
        <span
          key={index}
          className={`star ${
            index < (hoveredRating || rating) ? 'filled' : 'empty'
          }`}
          onMouseEnter={() => handleMouseEnter(index + 1)}
          onMouseLeave={handleMouseLeave}
          onClick={() => handleClick(index + 1)}
        >
          &#9733;
        </span>
      ))}
    </div>
  );
};

export default InteractiveRating;
