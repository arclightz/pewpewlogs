import { useApi } from './useApi';

export function useProfile() {
  const api = useApi();

  const getProfile = async () => {
    try {
      const response = await api.get('/users/profile');
      return response.data;
    } catch (error) {
      console.error('Error fetching user profile:', error);
      throw error;
    }
  };

  const updateProfile = async (profileData) => {
    try {
      const response = await api.put('/users/profile', profileData);
      return response.data;
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  };

  const updatePreferredWeapon = async (weaponId) => {
    try {
      const response = await api.put('/users/preferred-weapon', { weaponId });
      return response.data;
    } catch (error) {
      console.error('Error updating preferred weapon:', error);
      throw error;
    }
  };

  return {
    getProfile,
    updateProfile,
    updatePreferredWeapon,
  };
}