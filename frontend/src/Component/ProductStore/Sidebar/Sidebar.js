import React from 'react';
import './Sidebar.css';
import filterIcon from '../../Assets/filter_price.png';
import categoryIcon from '../../Assets/category.png';

const Sidebar = ({ categories, priceRanges, filterByCategory, filterByPriceRange }) => {
  return (
    <div className="sidebar-container">
      <div className="shop-sidebar mt-65">
        <div className="widget widget-menu">
          <h4 className="widget-title">
            <img src={categoryIcon} alt="Category Icon" className="widget-icon" />
            Category
          </h4>
          <ul>
            <li>
              <a href="#" onClick={() => filterByCategory(null)}>All</a> <span>({categories.reduce((acc, [_, count]) => acc + count, 0)})</span>
            </li>
            {categories.map(([category, count], index) => (
              <li key={index}>
                <a href="#" onClick={() => filterByCategory(category)}>{category}</a> <span>({count})</span>
              </li>
            ))}
          </ul>
        </div>

        <div className="widget widget-menu">
          <h4 className="widget-title">
            <img src={filterIcon} alt="Filter Icon" className="widget-icon" />
            Filter By Pricing
          </h4>
          <ul>
            {priceRanges.map(([range, count], index) => (
              <li key={index}>
                <a href="#" onClick={() => filterByPriceRange(range)}>{range}</a> <span>({count})</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;
