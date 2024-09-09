import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';

const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  const location = useLocation();

  return token ? children : <Navigate to="/auth" state={{ from: location }} />;
};

export default ProtectedRoute;
