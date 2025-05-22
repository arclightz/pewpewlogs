// frontend/src/services/authService.js
import axios from 'axios'; // Assuming you have axios installed (npm install axios)
import state from './state'; // Import your global state
import router from '../router'; // Import your router to handle redirects

// Determine API base URL. Use environment variable for production.
// For development, it will likely be your backend service in Docker Compose.
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://pewpewlogs.mrdj.stream';

// This line explicitly "uses" the 'state' object to satisfy linters
// that might otherwise report it as 'declared but never read'.
// It has no side effects on the application's logic.
void state; // Fix for 'state' declared but never read warning

const authService = {
  /**
   * Registers a new user with the backend.
   * @param {string} name - User's name.
   * @param {string} email - User's email.
   * @param {string} password - User's password.
   * @returns {Promise<Object>} - Response from the backend.
   */
  async register(name, email, password) {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/auth/register`, {
        name,
        email,
        password,
      });
      return response.data; // Returns { message: 'User registered successfully. Please log in.' }
    } catch (error) {
      console.error('Registration error:', error.response?.data || error.message);
      throw error.response?.data || new Error('Registration failed');
    }
  },

  /**
   * Logs in a user and stores the JWT token.
   * @param {string} email - User's email.
   * @param {string} password - User's password.
   * @returns {Promise<Object>} - User data from the backend.
   */
  async login(email, password) {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/auth/login`, {
        email,
        password,
      });

      const { token, user } = response.data;

      // Store the JWT token in localStorage
      localStorage.setItem('token', token);

      // Update global state with user information
      state.user = user;

      return user; // Return the user object
    } catch (error) {
      console.error('Login error:', error.response?.data || error.message);
      throw error.response?.data || new Error('Login failed');
    }
  },

  /**
   * Logs out the user by removing the token and clearing state.
   */
  logout() {
    localStorage.removeItem('token'); // Remove token from localStorage
    state.user = null; // Clear user from global state
    router.push('/login'); // Redirect to login page
  },

  /**
   * Checks if a user is currently authenticated based on the presence of a token.
   * This is a simple check for UI purposes.
   * @returns {boolean} - True if a token exists, false otherwise.
   */
  isAuthenticated() {
    return !!localStorage.getItem('token');
  },

  /**
   * Fetches the current user's profile from the backend using the stored token.
   * This is useful for populating `state.user` on page refresh if the token exists.
   * Assumes you'll have a backend route like /api/auth/me that returns user data.
   * (You'll need to implement this route in your backend if it doesn't exist).
   */
  async fetchCurrentUser() {
    const token = localStorage.getItem('token');
    if (!token) {
      state.user = null; // Clear state.user if no token
      return null;
    }

    try {
      // Assuming your backend has a route like /api/auth/me that returns the logged-in user's data
      const response = await axios.get(`${API_BASE_URL}/api/auth/me`, {
        headers: {
          'x-auth-token': token,
        },
      });
      state.user = response.data.user; // Update state.user with fetched data
      return response.data.user;
    } catch (error) {
      console.error('Failed to fetch current user:', error.response?.data || error.message);
      // If token is invalid or expired, clear it and log out
      this.logout();
      throw error.response?.data || new Error('Failed to fetch user');
    }
  },
};

export default authService;
