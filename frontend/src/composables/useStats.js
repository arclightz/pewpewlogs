// frontend/src/composables/useStats.js
import { ref } from 'vue';
import api from '../services/api'; // Import the configured axios instance
import { useApi } from './useApi'; // Import the general useApi composable

/**
 * A Vue composable for fetching and managing application statistics.
 */
export function useStats() {
  const stats = ref(null); // Reactive object to store statistics
  const { data, loading, error, execute } = useApi(); // Use the general API composable

  /**
   * Fetches overall and per-weapon statistics for the authenticated user.
   */
  const fetchStats = async () => {
    try {
      const responseData = await execute(api.get, '/api/stats');
      stats.value = responseData; // Assuming API returns an object with 'overall' and 'shotsPerWeapon'
    } catch (err) {
      console.error('Failed to fetch statistics:', err);
      // Error state is already handled by useApi, but specific handling can go here
    }
  };

  return {
    stats,
    loading,
    error,
    fetchStats,
  };
}
