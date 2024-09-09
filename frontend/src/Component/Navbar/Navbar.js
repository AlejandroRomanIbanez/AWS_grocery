import React, { useState, useEffect } from 'react';
import "./Navbar.css";
import { FaBars } from 'react-icons/fa';
import { useNavigate } from 'react-router-dom';

const Navbar = () => {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [isMobile, setIsMobile] = useState(window.innerWidth < 768);
    const navigate = useNavigate();

    const toggleMenu = () => {
        setIsMenuOpen(!isMenuOpen);
    };

    const handleResize = () => {
        setIsMobile(window.innerWidth < 768);
        if (window.innerWidth >= 768) {
            setIsMenuOpen(false);
        }
    };

    const handleScrollToBottom = (e) => {
        e.preventDefault();
        window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
    };

    useEffect(() => {
        window.addEventListener('resize', handleResize);
        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, []);

    return (
        <div className='navbar-container'>
            <div className='navbar-sub-container'>
                {isMobile && (
                    <div className='burger-menu' onClick={toggleMenu}>
                        <FaBars size={28} />
                    </div>
                )}

                {isMobile && isMenuOpen ? (
                    <div className="mobile-menu">
                        <ul className='anim-nav'>
                            <li><a href="/" onClick={() => navigate('/')}>Home</a></li>
                            <li><a href="/store" onClick={() => navigate('/store')}>Shop</a></li>
                            <li><a href="/store/favs" onClick={() => navigate('/store/favs')}>Favorites</a></li>
                            <li><a href="#!" onClick={handleScrollToBottom}>Contact</a></li>
                        </ul>
                    </div>
                ) : (
                    <div className={`navbar ${isMenuOpen ? 'active' : ''}`}>
                        <ul className='anim-nav'>
                            <li><a href="/" onClick={() => navigate('/')}>Home</a></li>
                            <li><a href="/store" onClick={() => navigate('/store')}>Shop</a></li>
                            <li><a href="/store/favs" onClick={() => navigate('/store/favs')}>Favorites</a></li>
                            <li><a href="#!" onClick={handleScrollToBottom}>Contact</a></li>
                        </ul>
                    </div>
                )}
            </div>
        </div>
    );
};

export default Navbar;
