// frontend/src/services/api.js
import axios from 'axios';
import router from '../router';
import authService from './authService';

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
    console.log(`[Axios Interceptor] Token in localStorage (before send): ${!!token ? 'Present' : 'Absent'}`);
    if (token) {
      config.headers['x-auth-token'] = token;
      console.log(`[Axios Interceptor] x-auth-token header set for request to: ${config.url}`);
    } else {
      console.warn(`[Axios Interceptor] No token found for request to: ${config.url}. Request will be unauthenticated.`);
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
  async (error) => {
    if (error.response && error.response.status === 401) {
      if (!error.config.url.includes('/api/auth/login')) {
        console.error('Unauthorized API request (401): Token might be expired or invalid. Redirecting to login...');
        
        authService.logout();
        
        if (router.currentRoute.value.name !== 'Login') {
          router.push({ name: 'Login' });
        }
      } else {
        console.warn('Login attempt returned 401. Not redirecting.');
      }
    }
    return Promise.reject(error);
  }
);

export default api;
