import React, { useState } from 'react';
import './AgeVerificationModal.css';

const AgeVerificationModal = ({ show, onClose, onConfirm }) => {
  const [birthDate, setBirthDate] = useState('');

  const handleConfirm = () => {
    const parts = birthDate.split('-');
    if (parts.length === 3) {
      const day = parts[0];
      const month = parts[1];
      const year = parts[2];
      const birthDateObj = new Date(`${year}-${month}-${day}`);

      let age = new Date().getFullYear() - birthDateObj.getFullYear();
      const monthDiff = new Date().getMonth() - birthDateObj.getMonth();
      const dayDiff = new Date().getDate() - birthDateObj.getDate();
      if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
        age--;
      }

      if (age >= 18) {
        onConfirm(true);
      } else {
        onConfirm(false);
      }
    } else {
      onConfirm(false);
    }
  };

  if (!show) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <h2>Age Verification</h2>
        <p>You need to be +18 to see some products. Please enter your birth date:</p>
        <input
          type="text"
          value={birthDate}
          onChange={(e) => setBirthDate(e.target.value)}
          placeholder="DD-MM-YYYY"
        />
        <button onClick={handleConfirm}>Confirm</button>
      </div>
    </div>
  );
};

export default AgeVerificationModal;
