import api from '../services/api.js';

export function useWeapons() {
  const getWeapons = async () => {
    try {
      const response = await api.get('/weapons');
      return response.data;
    } catch (error) {
      console.error('Error fetching weapons:', error);
      throw error;
    }
  };

  const getWeapon = async (weaponId) => {
    try {
      const response = await api.get(`/weapons/${weaponId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching weapon:', error);
      throw error;
    }
  };

  const createWeapon = async (weaponData) => {
    try {
      const response = await api.post('/weapons', weaponData);
      return response.data;
    } catch (error) {
      console.error('Error creating weapon:', error);
      throw error;
    }
  };

  const updateWeapon = async (weaponId, weaponData) => {
    try {
      const response = await api.put(`/weapons/${weaponId}`, weaponData);
      return response.data;
    } catch (error) {
      console.error('Error updating weapon:', error);
      throw error;
    }
  };

  const deleteWeapon = async (weaponId) => {
    try {
      await api.delete(`/weapons/${weaponId}`);
    } catch (error) {
      console.error('Error deleting weapon:', error);
      throw error;
    }
  };

  return {
    getWeapons,
    getWeapon,
    createWeapon,
    updateWeapon,
    deleteWeapon,
  };
}