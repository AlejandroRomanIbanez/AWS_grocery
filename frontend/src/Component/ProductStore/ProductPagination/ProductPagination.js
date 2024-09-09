import React from 'react';
import './ProductPagination.css';

const Pagination = ({ currentPage, totalPages, onPageChange }) => {
  const pages = Array.from({ length: totalPages }, (_, index) => index + 1);

  return (
    <nav aria-label="Page navigation">
      <ul className="pagination">
        <li className={`pagination-item ${currentPage === 1 ? 'disabled' : ''}`}>
          <button 
            className="pagination-link" 
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 1}
          >
            Previous
          </button>
        </li>
        <div className="page-numbers">
          {pages.map(page => (
            <li key={page} className={`pagination-item ${page === currentPage ? 'active' : ''}`}>
              <button 
                className="pagination-link" 
                onClick={() => onPageChange(page)}
              >
                {page}
              </button>
            </li>
          ))}
        </div>
        <li className={`pagination-item ${currentPage === totalPages ? 'disabled' : ''}`}>
          <button 
            className="pagination-link" 
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
          >
            Next
          </button>
        </li>
      </ul>
    </nav>
  );
};

export default Pagination;
