import React, { useState, useEffect } from 'react';
import './AvatarModal.css';
import useUserInfo from '../../hooks/useUserInfo'; // Import the custom hook
import { API_BASE_URL } from '../../config';

const AvatarModal = ({ isOpen, onClose }) => {
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const { avatarUrl, fetchUserInfo } = useUserInfo();
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  useEffect(() => {
    if (isOpen) {
      fetchUserInfo();
    }
  }, [isOpen, fetchUserInfo]);

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0];
    if (selectedFile) {
      setFile(selectedFile);
      setPreview(URL.createObjectURL(selectedFile));
    }
  };

  const handleUpload = async () => {
    if (file) {
      const formData = new FormData();
      formData.append('file', file);

      try {
        const response = await fetch(`${API_BASE_URL}/api/me/avatar`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${localStorage.getItem('token')}`,
          },
          body: formData,
        });

        const result = await response.json();

        if (response.ok) {
          setSuccessMessage('Avatar uploaded successfully');
          setPreview(null);
          setFile(null);
          fetchUserInfo();
        } else {
          setErrorMessage(result.error || 'Failed to upload avatar');
        }
      } catch (error) {
        setErrorMessage('Error uploading avatar');
      }
    }
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <div className="modal-header">
          <h2>Update Your Avatar</h2>
          <button className="close-button" onClick={onClose}>X</button>
        </div>
        <div className="modal-body">
          {preview ? (
            <img src={preview} alt="Avatar Preview" className="avatar-preview" />
          ) : avatarUrl ? (
            <img src={avatarUrl} alt="Current Avatar" className="avatar-preview" />
          ) : (
            <div className="upload-placeholder">No avatar available</div>
          )}
          <input type="file" accept="image/*" onChange={handleFileChange} />
          {errorMessage && <p className="error-message">{errorMessage}</p>}
          {successMessage && <p className="success-message">{successMessage}</p>}
        </div>
        <div className="modal-footer">
          <button className="upload-button" onClick={handleUpload} disabled={!file}>
            Upload Avatar
          </button>
        </div>
      </div>
    </div>
  );
};

export default AvatarModal;
