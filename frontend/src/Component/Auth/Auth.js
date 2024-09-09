import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast, Toaster } from 'react-hot-toast'; // Import react-hot-toast
import './Auth.css';
import logo from '../Assets/Frame2.png';

const Auth = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    setIsAuthenticated(!!token);
  }, []);

  const handleSwitch = () => {
    setIsLogin(!isLogin);
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    setIsAuthenticated(false);
    toast.success('Logged out successfully.');
  };

  return (
    <div className="auth-wrapper">
      <div className="auth-container">
        <div className="auth-form-container">
          <div className="auth-form">
            <div className="auth-form-header">
              <img 
                src={logo}
                alt="logo" 
                className="logo"
              />
              <h4 className="header-title">We are MarketMate</h4>
            </div>
            {isAuthenticated ? (
              <>
                <button onClick={handleLogout} className="logout-btn">Logout</button>
                <a href="#!" onClick={(e) => { e.preventDefault(); navigate('/'); }} className="home-link">Go to Home</a>
              </>
            ) : (
              isLogin ? <LoginForm handleSwitch={handleSwitch} /> : <RegisterForm handleSwitch={handleSwitch} />
            )}
          </div>
        </div>
        <div className="auth-info">
          <h4>We're here to help you navigate the aisles and find what you need</h4>
          <p>At MarketMate, we believe that shopping should be a breeze, not a chore. That's why we're dedicated to providing you with a personalized shopping experience that's tailored to your needs and preferences.</p>
        </div>
      </div>
      <Toaster /> {/* Add the Toaster component to display toasts */}
    </div>
  );
};

const LoginForm = ({ handleSwitch }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(`${process.env.REACT_APP_BACKEND_SERVER}/api/auth/login`, { email, password });
      console.log(response.data);
      localStorage.setItem('token', response.data.access_token);
      window.location.href = '/';
    } catch (error) {
      console.error(error.response.data);
      toast.error('Invalid username or password');
    }
  };

  return (
    <form className="form" onSubmit={handleSubmit}>
      <input type="email" placeholder="Email address" className="form-input" required value={email} onChange={(e) => setEmail(e.target.value)} />
      <input type="password" placeholder="Password" className="form-input" required value={password} onChange={(e) => setPassword(e.target.value)} />
      <button type="submit" className="submit-btn">Sign In</button>
      <a href="#!" onClick={(e) => { e.preventDefault(); handleSwitch(); }} className="switch-link">Create a new account</a>
      <a href="#!" onClick={(e) => { e.preventDefault(); navigate('/'); }} className="home-link">Go to Home</a>
    </form>
  );
};

const RegisterForm = ({ handleSwitch }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(`${process.env.REACT_APP_BACKEND_SERVER}/api/auth/register`, { username: name, email, password });
      console.log(response.data);
      handleSwitch();
      toast.success('Registration successful. Please log in.');
    } catch (error) {
      console.error(error);
      const errorMessage = error?.response?.data?.error || 'Registration failed. Please try again.';
      toast.error(errorMessage);
    }
  };

  return (
    <form className="form" onSubmit={handleSubmit}>
      <input type="text" placeholder="Full Name" className="form-input" required value={name} onChange={(e) => setName(e.target.value)} />
      <input type="email" placeholder="Email address" className="form-input" required value={email} onChange={(e) => setEmail(e.target.value)} />
      <input type="password" placeholder="Password" className="form-input" required value={password} onChange={(e) => setPassword(e.target.value)} />
      <button type="submit" className="submit-btn">Sign Up</button>
      <a href="#!" onClick={(e) => { e.preventDefault(); handleSwitch(); }} className="switch-link">Already have an account? Login</a>
      <a href="#!" onClick={(e) => { e.preventDefault(); navigate('/'); }} className="home-link">Go to Home</a>
    </form>
  );
};

export default Auth;
