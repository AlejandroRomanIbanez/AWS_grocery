// ProductGridSkeleton.jsx
import React from 'react';
import './ProductGridSkeleton.css';

const ProductGridSkeleton = () => {
  return (
    <div className="product-grid-skeleton">
      {Array.from({ length: 12 }).map((_, index) => (
        <div className="product-card-skeleton" key={index}></div>
      ))}
    </div>
  );
};

export default ProductGridSkeleton;
