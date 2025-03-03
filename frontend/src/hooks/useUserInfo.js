import { useState, useEffect } from 'react';
import { API_BASE_URL } from '../config';

const useUserInfo = () => {
  const [username, setUsername] = useState('');
  const [avatarUrl, setAvatarUrl] = useState(null);
  const [users, setUsers] = useState([]);
  const [s3Config, setS3Config] = useState({
    USE_S3_STORAGE: false,
    S3_BUCKET: '',
    S3_REGION: ''
  });

  useEffect(() => {
    fetchConfig();
  }, []);

  const fetchConfig = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/config`);
      if (response.ok) {
        const configData = await response.json();
        setS3Config(configData);
      } else {
        console.error("Failed to fetch config");
      }
    } catch (error) {
      console.error("Error fetching config:", error);
    }
  };

  const fetchUserInfo = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/me/info`, {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsername(data.username);
        setAvatarUrl(data.avatar);
      } else {
        console.error('Failed to fetch user info');
      }
    } catch (error) {
      console.error('Error fetching user info:', error);
    }
  };

  const fetchAllUsers = async () => {
    try {
      const response = await fetch(`${API_BASE_URL}/api/me/all-users`, {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsers(data); // Update the users list
      } else {
        console.error('Failed to fetch users');
      }
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const updateAvatarInState = (newAvatar) => {
    const newAvatarUrl = newAvatar;
    setAvatarUrl(newAvatarUrl);
    
    // Update the users list locally to reflect the new avatar for the current user
    setUsers((prevUsers) =>
      prevUsers.map((user) =>
        user.username === username ? { ...user, avatar: newAvatar } : user
      )
    );
  };

  useEffect(() => {
    fetchUserInfo();
    fetchAllUsers();
  }, []);

  const getAvatarUrl = (username) => {
  const user = users.find((user) => user.username === username);

  if (user && user.avatar) {
    // User has an avatar, use whatever URL backend provides
    return user.avatar;  // This is already the proxy URL from backend
  }

  // Default avatar through backend proxy
  return `${process.env.REACT_APP_BACKEND_SERVER}/api/me/avatar/user_default.png`;
};
  return {
    username,
    avatarUrl,
    users,
    getAvatarUrl,
    fetchUserInfo,
    updateAvatarInState, // This will update the avatar directly
  };
};

export default useUserInfo;
