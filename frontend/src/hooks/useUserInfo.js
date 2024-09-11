import { useState, useEffect } from 'react';

const useUserInfo = () => {
  const [username, setUsername] = useState('');
  const [avatarUrl, setAvatarUrl] = useState(null);
  const [users, setUsers] = useState([]);

  const fetchUserInfo = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/info`, {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('token')}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        setUsername(data.username);
        setAvatarUrl(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/avatar/${data.avatar || 'user_default.png'}`);
      } else {
        console.error('Failed to fetch user info');
      }
    } catch (error) {
      console.error('Error fetching user info:', error);
    }
  };

  const fetchAllUsers = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_BACKEND_SERVER}/api/me/all-users`, {
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
    const newAvatarUrl = `${process.env.REACT_APP_BACKEND_SERVER}/api/me/avatar/${newAvatar}`;
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

  const getAvatarUrl = (author) => {
    const user = users.find((user) => user.username === author);
    return user
      ? `${process.env.REACT_APP_BACKEND_SERVER}/api/me/avatar/${user.avatar}`
      : `${process.env.REACT_APP_BACKEND_SERVER}/api/me/avatar/user_default.png`;
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
