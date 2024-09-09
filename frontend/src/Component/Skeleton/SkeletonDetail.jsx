import React from 'react';
import './SkeletonDetail.css';

const SkeletonDetail = () => {
  return (
    <section className="productDetailContainer">
      <div className="imageGalleryContainer">
        <div className="skeleton-image"></div>
      </div>
      <div className="descriptionContainer">
        <div className="skeleton-title"></div>
        <div className="skeleton-rating"></div>
        <div className="skeleton-category"></div>
        <div className="skeleton-price"></div>
      </div>
      <div className="skeleton-comments"></div>
    </section>
  );
};

export default SkeletonDetail;
