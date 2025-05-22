// frontend/src/services/api.js
import axios from 'axios';

// Determine API base URL from environment variables.
// In development, this will typically be your backend service in Docker Compose.
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to attach the JWT token to every outgoing request
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['x-auth-token'] = token; // Attach token as 'x-auth-token' header
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle token expiration or invalid tokens
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // If the error status is 401 (Unauthorized) and it's not a login attempt itself,
    // it might mean the token is expired or invalid.
    if (error.response && error.response.status === 401 && !error.config.url.includes('/api/auth/login')) {
      // You might want to automatically log out the user here
      // import authService from './authService'; // You'd need to import it here
      // authService.logout();
      // router.push('/login'); // Redirect to login
      console.error('Unauthorized API request. Token might be expired or invalid.');
    }
    return Promise.reject(error);
  }
);

export default api;
