// frontend/src/composables/useWeapons.js
import { ref } from 'vue';
import api from '../services/api'; // Import the configured axios instance
import { useApi } from './useApi'; // Import the general useApi composable

/**
 * A Vue composable for managing weapons.
 * Provides functions to fetch, create, and potentially update/delete weapons.
 */
export function useWeapons() {
  const weapons = ref([]); // Reactive array to store weapons
  const { data, loading, error, execute } = useApi(); // Use the general API composable

  /**
   * Fetches all weapons for the authenticated user.
   */
  const fetchWeapons = async () => {
    try {
      const responseData = await execute(api.get, '/api/weapons');
      weapons.value = responseData; // Store the full responseData directly
    } catch (err) {
      console.error('Failed to fetch weapons:', err);
      // Error state is already handled by useApi, but specific handling can go here
    }
  };

  /**
   * Creates a new weapon.
   * @param {Object} weaponData - The data for the new weapon (e.g., name, type).
   * @returns {Promise<Object>} The created weapon object.
   */
  const createWeapon = async (weaponData) => {
    try {
      const newWeapon = await execute(api.post, '/api/weapons', weaponData);
      weapons.value.push(newWeapon); // Add the new weapon to the local list
      return newWeapon;
    } catch (err) {
      console.error('Failed to create weapon:', err);
      throw err; // Re-throw for component to handle
    }
  };

  // You can add more functions here for updating, deleting, or fetching a single weapon.

  return {
    weapons,
    loading,
    error,
    fetchWeapons,
    createWeapon,
    // ... other weapon-related functions
  };
}
