import { useApi } from './useApi';

export function useStats() {
  const api = useApi();

  const getOverallStats = async () => {
    try {
      const response = await api.get('/stats/overall');
      return response.data;
    } catch (error) {
      console.error('Error fetching overall stats:', error);
      throw error;
    }
  };

  const getWeaponStats = async () => {
    try {
      const response = await api.get('/stats/weapons');
      return response.data;
    } catch (error) {
      console.error('Error fetching weapon stats:', error);
      throw error;
    }
  };

  const getRecentSessions = async (limit = 5) => {
    try {
      const response = await api.get(`/stats/recent-sessions?limit=${limit}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching recent sessions:', error);
      throw error;
    }
  };

  return {
    getOverallStats,
    getWeaponStats,
    getRecentSessions,
  };
}