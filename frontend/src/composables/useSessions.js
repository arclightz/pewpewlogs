// frontend/src/composables/useSessions.js
import { ref } from 'vue';
import api from '../services/api'; // Import the configured axios instance
import { useApi } from './useApi'; // Import the general useApi composable

/**
 * A Vue composable for managing shooting sessions.
 * Provides functions to fetch, create, and potentially update/delete sessions.
 */
export function useSessions() {
  const sessions = ref([]); // Reactive array to store sessions
  const { data, loading, error, execute } = useApi(); // Use the general API composable

  /**
   * Fetches all shooting sessions for the authenticated user.
   */
  const fetchSessions = async () => {
    try {
      const responseData = await execute(api.get, '/api/sessions');
      sessions.value = responseData; // Assuming API returns an array of sessions directly
    } catch (err) {
      console.error('Failed to fetch sessions:', err);
      // Error state is already handled by useApi, but specific handling can go here
    }
  };

  /**
   * Creates a new shooting session.
   * @param {Object} sessionData - The data for the new session (e.g., date, location, weaponId).
   * @returns {Promise<Object>} The created session object.
   */
  const createSession = async (sessionData) => {
    try {
      const newSession = await execute(api.post, '/api/sessions', sessionData);
      sessions.value.push(newSession); // Add the new session to the local list
      return newSession;
    } catch (err) {
      console.error('Failed to create session:', err);
      throw err; // Re-throw for component to handle
    }
  };

  // You can add more functions here for updating, deleting, or fetching a single session.

  return {
    sessions,
    loading,
    error,
    fetchSessions,
    createSession,
    // ... other session-related functions
  };
}
