// frontend/src/composables/useRanges.js
import { ref } from 'vue';
import api from '../services/api';
import { useApi } from './useApi';

/**
 * A Vue composable for managing shooting ranges.
 * Provides functions to fetch ranges.
 */
export function useRanges() {
  const ranges = ref([]);
  const { data, loading, error, execute } = useApi();

  /**
   * Fetches all shooting ranges.
   */
  const fetchRanges = async () => {
    try {
      const responseData = await execute(api.get, '/api/ranges');
      ranges.value = responseData;
    } catch (err) {
      console.error('Failed to fetch ranges:', err);
      // Error state is already handled by useApi, but specific handling can go here
    }
  };

  // You can add more functions here for creating, updating, deleting a single range.

  return {
    ranges,
    loading,
    error,
    fetchRanges,
  };
}
