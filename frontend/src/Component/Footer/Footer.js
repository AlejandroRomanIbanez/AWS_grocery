import React from 'react';
import "./Footer.css";
import logo from "../Assets/Frame2.png";
import payment from "../Assets/payment.png";
import vector1 from "../Assets/Vector1.png";
import vector2 from "../Assets/Vector2.png";
import vector3 from "../Assets/Vector3.png";
import vector4 from "../Assets/Vector4.png";
import vector5 from "../Assets/Vector5.png";
import vector6 from "../Assets/Vector6.png";
import vector7 from "../Assets/Vector7.png";
import vector8 from "../Assets/Vector8.png";
import vector9 from "../Assets/Vector9.png";
import vector10 from "../Assets/Vector10.png";
import vector11 from "../Assets/Vector11.png";
import { FaFacebookF, FaTiktok } from 'react-icons/fa';
import { BsInstagram, BsTwitter } from 'react-icons/bs';
import { Fade } from 'react-reveal';

const Footer = () => {
    const isAuthenticated = !!localStorage.getItem('token');

    return (
        <div className='footer-container'>
            <img src={vector1} className="vector absolute left-[25%] top-[18%]" alt="" />
            <img src={vector2} className="vector absolute left-[62%] top-[10%]" alt="" />
            <img src={vector3} className="vector absolute right-[-50px] top-[20%]" alt="" />
            <img src={vector4} className="vector absolute left-[-10px] top-[30%]" alt="" />
            <img src={vector5} className="vector absolute left-[30%] top-[44%]" alt="" />
            <img src={vector6} className="vector absolute left-[42%] top-[30%]" alt="" />
            <img src={vector7} className="vector absolute left-[55%] top-[42%]" alt="" />
            <img src={vector8} className="vector absolute left-[66.5%] top-[33%]" alt="" />
            <img src={vector9} className="vector absolute left-[29%] top-[65%]" alt="" />
            <img src={vector10} className="vector absolute left-[46%] top-[73%]" alt="" />
            <img src={vector11} className="vector absolute left-[65%] top-[70%]" alt="" />
            <img src={vector6} className="vector absolute right-[2%] top-[70%]" alt="" />
            <img src={vector3} className="vector absolute left-[20px] bottom-[20px]" alt="" />

            <div className='footer-top'>
                <div className='footer-logo-container'>
                    <img src={logo} className="footer-logo" alt="Logo" />
                </div>
                <div className='footer-social-contact'>
                    <h3 className='footer-contact'>Follow Us</h3>
                    <div className='footer-social-icons'>
                        <a href="https://www.facebook.com/JoinMasterschool" target="_blank" rel="noopener noreferrer" className='bottom-social-icon'>
                            <FaFacebookF className='text-white' />
                        </a>
                        <a href="https://www.instagram.com/joinmasterschool/" target="_blank" rel="noopener noreferrer" className='bottom-social-icon'>
                            <BsInstagram className='text-white' />
                        </a>
                        <a href="https://twitter.com/Masterschoolhq" target="_blank" rel="noopener noreferrer" className='bottom-social-icon'>
                            <BsTwitter className='text-white' />
                        </a>
                        <a href="https://www.tiktok.com/@masterschool.com?_t=8Y76OOEKUx0&_r=1" target="_blank" rel="noopener noreferrer" className='bottom-social-icon'>
                            <FaTiktok className='text-white' />
                        </a>
                    </div>
                </div>
                <div className='footer-payment-container'>
                    <img src={payment} alt="Payment Methods" className='footer-payment' />
                </div>
            </div>

            <div className='footer-line' />

            <div className='footer-bottom'>
                <Fade left delay={1000}>
                    <div className='footer-info'>
                        <h2 className="footer-title">Contact Us</h2>
                        <p>+34 453 435 768</p>
                        <p>hey@masterschool.com</p>
                    </div>
                </Fade>

                <Fade left delay={1500}>
                    <div className='footer-info'>
                        <h2 className="footer-title">Information</h2>
                        <a href='/'>Home</a>
                        <a href="/store">Shop</a>
                    </div>
                </Fade>

                <Fade left delay={2000}>
                    <div className='footer-info'>
                        <h2 className="footer-title">My Account</h2>
                        <a href="/store/favs">My Favorites</a>
                        {isAuthenticated ? (
                            <a href="/auth">Log Out</a>
                        ) : (
                            <>
                                <a href="/auth">Sign In</a>
                                <a href="/auth">Register</a>
                            </>
                        )}
                        <a href="/checkout">Shopping cart</a>
                    </div>
                </Fade>
            </div>
        </div>
    );
};

export default Footer;
