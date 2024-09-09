import React, { useState, useEffect } from 'react';
import { BiSearchAlt } from 'react-icons/bi';
import './Search.css';
import { useNavigate } from 'react-router-dom';

const Search = ({ products }) => {
    const [query, setQuery] = useState('');
    const [suggestions, setSuggestions] = useState([]);
    const navigate = useNavigate();

    useEffect(() => {
        const fetchSuggestions = () => {
            if (query.length > 1) {
                const filteredSuggestions = products.filter(product =>
                    product.name.toLowerCase().includes(query.toLowerCase())
                );
                setSuggestions(filteredSuggestions);
            } else {
                setSuggestions([]);
            }
        };

        const delayDebounceFn = setTimeout(() => {
            fetchSuggestions();
        }, 500); // Adjust delay for debounce

        return () => clearTimeout(delayDebounceFn);
    }, [query, products]);

    const handleSuggestionClick = (productId) => {
        navigate(`/product/${productId}`); // Navigate to the product page
    };


    return (
        <div className='search-cont'>
            <BiSearchAlt className='icon' />
            <input
                type="text"
                placeholder='Search Products'
                value={query}
                onChange={(e) => setQuery(e.target.value)}
            />
            {suggestions.length > 0 && (
                <div className='suggestions'>
                    {suggestions.map((suggestion) => (
                        <div 
                        key={suggestion._id} 
                        className='suggestion-item' 
                        onClick={() => handleSuggestionClick(suggestion._id)}
                    >
                        <p><strong>{suggestion.name}</strong></p>
                        <p>{suggestion.description}</p>
                        <p>{suggestion.price.toFixed(2)}€</p>
                    </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default Search;
