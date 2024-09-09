import React from 'react';
import './CustomRating.css';

const CustomRating = ({ rating }) => {
  const fullStars = Math.floor(rating);
  const fractionalPart = rating % 1;
  const emptyStars = 5 - fullStars - (fractionalPart > 0 ? 1 : 0);
  return (
    <div className="custom-rating">
      {[...Array(fullStars)].map((_, i) => (
        <span key={i} className="star full">&#9733;</span>
      ))}
      {fractionalPart > 0 && (
        <span className="star partial">
          <span className="filled" style={{ width: `${fractionalPart * 100}%` }}>&#9733;</span>
          <span className="unfilled">&#9733;</span>
        </span>
      )}
      {[...Array(emptyStars)].map((_, i) => (
        <span key={i} className="star empty">&#9733;</span>
      ))}
    </div>
  );
};

export default CustomRating;
