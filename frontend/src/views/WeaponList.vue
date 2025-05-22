<template>
  <div class="container mx-auto px-4 py-8 text-white">
    <h1 class="text-3xl font-bold mb-6 text-center">Your Weapons</h1>

    <div v-if="loading" class="text-center text-lg">Loading weapons...</div>
    <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ error }}</span>
    </div>
    <div v-else-if="weapons.length === 0" class="text-center text-lg text-blue-200">
      <p>No weapons registered yet.</p>
      <router-link to="/weapons/new" class="text-blue-400 hover:underline mt-4 block">Add your first weapon!</router-link>
    </div>
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="weapon in weapons" :key="weapon._id" class="bg-blue-800 p-6 rounded-lg shadow-md">
        <h3 class="text-xl font-semibold mb-2">{{ weapon.name }}</h3>
        <p class="text-blue-200 mb-1">Type: {{ weapon.type || 'N/A' }}</p>
        <p class="text-blue-200 mb-1" v-if="weapon.caliber">Caliber: {{ weapon.caliber }}</p>
        <p class="text-blue-200 mb-1">ERVA: {{ weapon.erva ? 'Yes' : 'No' }}</p>
        <p class="text-blue-200 mb-1" v-if="weapon.purchaseDate">
          Purchased: {{ new Date(weapon.purchaseDate).toLocaleDateString() }}
        </p>
        <p class="text-blue-200 mb-1" v-if="weapon.notes">Notes: {{ weapon.notes }}</p>
        <div class="mt-4 flex justify-end">
          <!-- <button class="bg-blue-600 hover:bg-blue-700 text-white py-1 px-3 rounded text-sm">
            Edit
          </button> -->
        </div>
      </div>
    </div>

    <div class="mt-8 text-center">
      <router-link
        to="/weapons/new"
        class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
      >
        Add New Weapon
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useWeapons } from '../composables/useWeapons'; // Import the weapon composable

const { weapons, loading, error, fetchWeapons } = useWeapons();

onMounted(() => {
  fetchWeapons(); // Fetch weapons when the component is mounted
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
