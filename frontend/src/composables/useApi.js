// frontend/src/composables/useApi.js
import { ref } from 'vue';
import api from '../services/api'; // Import the configured axios instance

/**
 * A Vue composable for making API requests.
 * Provides loading, error, and data states.
 * @returns {Object} An object containing data, loading, error, and a request function.
 */
export function useApi() {
  const data = ref(null);
  const loading = ref(false);
  const error = ref(null);

  /**
   * Executes an API request.
   * @param {Function} requestFn - The Axios request function (e.g., `api.get('/sessions')`).
   * @param {Object} [params] - Optional parameters to pass to the request function.
   * @returns {Promise<any>} The response data.
   */
  const execute = async (requestFn, ...params) => {
    loading.value = true;
    error.value = null;
    try {
      const response = await requestFn(...params);
      data.value = response.data;
      return response.data;
    } catch (err) {
      error.value = err.response?.data?.message || err.message || 'An unknown error occurred.';
      console.error('API request failed:', err);
      throw error; // Re-throw to allow component-level error handling
    } finally {
      loading.value = false;
    }
  };

  return {
    data,
    loading,
    error,
    execute,
  };
}
