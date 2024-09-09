import React, { useState, useEffect, useRef } from 'react';
import './ProductHeader.css';

const ProductHeader = ({ sortOption, sortDirection, sortProducts }) => {
  const [isSelectOpen, setIsSelectOpen] = useState(false);
  const selectContainerRef = useRef(null);

  const options = ["Suggested", "Name", "Price"];

  const handleOptionClick = (option) => {
    sortProducts(option);
    setIsSelectOpen(false);
  };

  const toggleSelectOpen = () => {
    setIsSelectOpen(!isSelectOpen);
  };

  const handleClickOutside = (event) => {
    if (selectContainerRef.current && !selectContainerRef.current.contains(event.target)) {
      setIsSelectOpen(false);
    }
  };

  const getSortArrow = (option) => {
    if (option === "Suggested" || option !== sortOption) return null;
    return sortDirection === "asc" ? "▲" : "▼";
  };

  useEffect(() => {
    if (isSelectOpen) {
      document.addEventListener('click', handleClickOutside);
    } else {
      document.removeEventListener('click', handleClickOutside);
    }
    return () => {
      document.removeEventListener('click', handleClickOutside);
    };
  }, [isSelectOpen]);

  return (
    <header className="product-header">
      <div className="ms-auto d-flex align-items-center">
        <div ref={selectContainerRef} className={`custom-select-container ${isSelectOpen ? 'select-open' : ''}`}>
          <div className="custom-select" onClick={toggleSelectOpen}>
            {sortOption}
          </div>
          {isSelectOpen && (
            <div className="custom-options">
              {options.map((option, index) => (
                <div
                  key={index}
                  className="custom-option"
                  onClick={() => handleOptionClick(option)}
                >
                  {option} {getSortArrow(option)}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default ProductHeader;
