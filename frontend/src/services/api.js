// frontend/src/services/api.js
import axios from 'axios';
import router from '../router'; // Import the router instance
import authService from './authService'; // Import authService for logout

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
      console.error('Unauthorized API request: Token might be expired or invalid. Redirecting to login...');
      
      // You might want to automatically log out the user here
      authService.logout();
      if (router.currentRoute.value.path !== 'Login') {
        // Redirect to the login page if not already there
        router.replace({ name: 'Login' });
      }
      router.push('/login'); // Redirect to login
      
    }
    return Promise.reject(error);
  }
);

export default api;
