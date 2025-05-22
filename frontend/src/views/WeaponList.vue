<template>
  <div class="px-4 py-8 relative min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Your Weapons</h1>
      <div class="flex items-center space-x-4">
        <button class="text-white hover:text-blue-200 focus:outline-none">
          <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01.293.707V19a1 1 0 01-1 1H4a1 1 0 01-1-1V4zm0 0L9 12m-6 0h6m-6 0h.01"></path>
          </svg>
        </button>
        <button class="text-white hover:text-blue-200 focus:outline-none">
          <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center text-lg">Loading weapons...</div>
    <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ error }}</span>
    </div>
    <div v-else-if="weapons.length === 0" class="text-center text-lg text-blue-200 mt-10">
      <p>No weapons registered yet.</p>
      <p class="mt-2">Click the '+' button to add your first weapon!</p>
    </div>
    <div v-else class="overflow-x-auto bg-gray-800 rounded-lg shadow-lg">
      <table class="min-w-full divide-y divide-gray-700">
        <thead class="bg-blue-700">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Name</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Type</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Caliber</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">ERVA</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Purchase Date</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Notes</th>
            </tr>
        </thead>
        <tbody class="divide-y divide-gray-700">
          <tr v-for="weapon in weapons" :key="weapon._id" class="hover:bg-gray-700 transition-colors duration-200">
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ weapon.name }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ weapon.type || 'N/A' }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ weapon.caliber || 'N/A' }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ weapon.erva ? 'Yes' : 'No' }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ weapon.purchaseDate ? new Date(weapon.purchaseDate).toLocaleDateString() : 'N/A' }}</td>
            <td class="px-6 py-4 text-sm text-gray-300 max-w-xs truncate">{{ weapon.notes || '-' }}</td>
            </tr>
        </tbody>
      </table>
    </div>

    <router-link
      to="/weapons/new"
      class="fixed bottom-8 right-8 bg-green-500 hover:bg-green-600 text-white p-4 rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-110 focus:outline-none"
    >
      <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
      </svg>
    </router-link>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useWeapons } from '../composables/useWeapons';

const { weapons, loading, error, fetchWeapons } = useWeapons();

onMounted(() => {
  fetchWeapons();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
