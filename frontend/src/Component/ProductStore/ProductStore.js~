import React, { useEffect, useState } from 'react';
import ProductGrid from '../ProductStore/ProductGrid/ProductGrid';
import ProductHeader from '../ProductStore/ProductHeader/ProductHeader';
import Sidebar from './Sidebar/Sidebar';
import './ProductStore.css';
import axios from 'axios';

const ProductStore = ({ products, isFav, basket, setBasket }) => {
  const [filteredProducts, setFilteredProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [priceRanges, setPriceRanges] = useState([]);
  const [sortOption, setSortOption] = useState("Suggested");
  const [sortDirection, setSortDirection] = useState("asc");
  const [favProducts, setFavProducts] = useState([]);
  const [resetPage, setResetPage] = useState(false);

  useEffect(() => {
    const fetchFavorites = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/favorites`, {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });
        setFavProducts(response.data);
      } catch (error) {
        console.error('Failed to fetch favorites:', error);
      }
    };

    fetchFavorites();
  }, []);

  useEffect(() => {
    const calculateCategoriesAndPriceRanges = (products) => {
      const categoriesMap = {};
      const priceRangeMap = {
        '0€ - 5€': 0,
        '5€ - 10€': 0,
        '10€ - 20€': 0,
        '20€ - 50€': 0,
        '50€ - 100€': 0,
        '100€ - 200€': 0,
        '200€+': 0,
      };

      products.forEach(product => {
        // Category count
        if (categoriesMap[product.category]) {
          categoriesMap[product.category]++;
        } else {
          categoriesMap[product.category] = 1;
        }

        // Price range count
        if (product.price <= 5) {
          priceRangeMap['0€ - 5€']++;
        } else if (product.price <= 10) {
          priceRangeMap['5€ - 10€']++;
        } else if (product.price <= 20) {
          priceRangeMap['10€ - 20€']++;
        } else if (product.price <= 50) {
          priceRangeMap['20€ - 50€']++;
        } else if (product.price <= 100) {
          priceRangeMap['50€ - 100€']++;
        } else if (product.price <= 200) {
          priceRangeMap['100€ - 200€']++;
        } else {
          priceRangeMap['200€+']++;
        }
      });

      return {
        categories: Object.entries(categoriesMap),
        priceRanges: Object.entries(priceRangeMap)
      };
    };

    const { categories: productCategories, priceRanges: productPriceRanges } = calculateCategoriesAndPriceRanges(products);
    const { categories: favCategories, priceRanges: favPriceRanges } = calculateCategoriesAndPriceRanges(favProducts);

    setCategories(isFav ? favCategories : productCategories);
    setPriceRanges(isFav ? favPriceRanges : productPriceRanges);

    setFilteredProducts(isFav ? favProducts : products);
  }, [products, favProducts, isFav]);

  const filterByCategory = (category) => {
    setResetPage(prev => !prev);
    const filtered = category ? (isFav ? favProducts : products).filter(product => product.category === category) : (isFav ? favProducts : products);
    setFilteredProducts(filtered);
    setSortOption("Suggested");
  };

  const filterByPriceRange = (range) => {
    setResetPage(prev => !prev);
    const filtered = (isFav ? favProducts : products).filter(product => {
      if (range === '0€ - 5€') return product.price <= 5;
      if (range === '5€ - 10€') return product.price > 5 && product.price <= 10;
      if (range === '10€ - 20€') return product.price > 10 && product.price <= 20;
      if (range === '20€ - 50€') return product.price > 20 && product.price <= 50;
      if (range === '50€ - 100€') return product.price > 50 && product.price <= 100;
      if (range === '100€ - 200€') return product.price > 100 && product.price <= 200;
      if (range === '200€+') return product.price > 200;
      return true;
    });
    setFilteredProducts(filtered);
    setSortOption("Suggested");
  };

  const sortProducts = (option) => {
    let sortedProducts = [...filteredProducts];
    let newSortDirection = sortDirection;

    if (option === "Suggested") {
      setFilteredProducts(isFav ? favProducts : products);
      setSortOption("Suggested");
      setSortDirection("asc");
      return;
    }

    if (option === sortOption) {
      newSortDirection = sortDirection === "asc" ? "desc" : "asc";
    } else {
      setSortOption(option);
      newSortDirection = "asc";
    }

    const directionMultiplier = newSortDirection === "asc" ? 1 : -1;
    if (option === "Name") {
      sortedProducts.sort((a, b) => a.name.localeCompare(b.name) * directionMultiplier);
    } else if (option === "Price") {
      sortedProducts.sort((a, b) => (a.price - b.price) * directionMultiplier);
    }

    setSortDirection(newSortDirection);
    setFilteredProducts(sortedProducts);
  };

  useEffect(() => {
    setFilteredProducts(isFav ? favProducts : products);
  }, [isFav, favProducts, products]);

  return (
    <div className="product-store-container">
      <Sidebar
        categories={categories}
        priceRanges={priceRanges}
        filterByCategory={filterByCategory}
        filterByPriceRange={filterByPriceRange}
      />
      <div className="main-content">
        <ProductHeader sortOption={sortOption} sortDirection={sortDirection} sortProducts={sortProducts} />
        <ProductGrid
          products={filteredProducts}
          isFav={isFav}
          basket={basket}
          setBasket={setBasket}
          filterByCategory={filterByCategory}
          resetPage={resetPage}
        />
      </div>
    </div>
  );
};

export default ProductStore;
