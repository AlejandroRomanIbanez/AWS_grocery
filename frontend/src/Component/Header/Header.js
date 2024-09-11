import React, { useState } from 'react';
import './Header.css';
import AvatarModal from './AvatarModal';  // Import the AvatarModal component
import logo from '../Assets/Frame2.png';
import callicon from '../Assets/call icon.svg';
import { BiUser } from 'react-icons/bi';
import { BsHeart, BsCart2 } from 'react-icons/bs';
import Search from '../Search/Search';
import { useNavigate } from 'react-router-dom';
import useUserInfo from '../../hooks/useUserInfo'; // Import the custom hook

const Header = ({ products }) => {
  const [showDropdown, setShowDropdown] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { avatarUrl, fetchUserInfo } = useUserInfo(); // Use the custom hook to get avatar URL and fetchUserInfo function
  const navigate = useNavigate();

  const toggleDropdown = () => {
    setShowDropdown(!showDropdown);
  };

  const openModal = () => {
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    fetchUserInfo(); // Refetch user info to get the updated avatar when modal closes
  };

  return (
    <div className="header-container">
      <div className="logo-search-cont">
        <img src={logo} alt="Logo" />
        <div className="search-cont">
          <Search products={products} />
        </div>
      </div>
      <div className="contact-social-cont">
        <div className="contact">
          <img src={callicon} alt="Call Icon" />
          <p>Call Us <br /> <span>+34 453 435 768</span></p>
        </div>
        <div className="social-icon-cont">
          <div className="headerIcon" onClick={toggleDropdown} style={{ position: 'relative' }}>
            <BiUser className="headerIcon-size" />
            {showDropdown && (
              <div className="dropdown">
                <div className="dropdown-item" onClick={() => navigate('/auth')}>
                  Authentication
                </div>
                <div className="dropdown-item" onClick={openModal}>
                  {/* Avatar image next to the Upload Avatar option */}
                  {avatarUrl && (
                    <img src={avatarUrl} alt="User Avatar" className="dropdown-avatar" />
                  )}
                  Avatar
                </div>
              </div>
            )}
          </div>
          <div className="headerIcon" onClick={() => navigate('/store/favs')}>
            <BsHeart className="headerIcon-size" />
          </div>
          <div className="headerIcon" onClick={() => navigate('/checkout')}>
            <BsCart2 className="headerIcon-size" />
          </div>
        </div>
      </div>
      {/* Avatar Modal */}
      <AvatarModal isOpen={isModalOpen} onClose={closeModal} />
    </div>
  );
};

export default Header;
