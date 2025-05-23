<template>
  <div class="px-4 py-8 relative min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Ampumaratasi</h1>
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

    <div v-if="loading" class="text-center text-lg text-gray-300">Ladataan ampumaratoja...</div>
    <div v-else-if="error" class="bg-red-800 text-white px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">Virhe ampumaratojen latauksessa: {{ error }}</span>
    </div>
    <div v-else-if="ranges.length === 0" class="text-center text-lg text-gray-300 mt-10">
      <p>Ei ampumaratoja tallennettu vielä.</p>
      <p class="mt-2">Napsauta '+' -painiketta lisätäksesi ensimmäisen ampumaradan!</p>
    </div>
    <div v-else>
      <div class="hidden md:block overflow-x-auto bg-gray-800 rounded-lg shadow-lg">
        <table class="min-w-full divide-y divide-gray-700">
          <thead class="bg-gray-700">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Nimi</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Osoite</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Koordinaatit</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Muistiinpanot</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Verkkosivusto</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Puhelin</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-700">
            <tr v-for="range in ranges" :key="range._id" class="hover:bg-gray-700 transition-colors duration-200">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ range.name }}</td>
              <td class="px-6 py-4 text-sm text-gray-300">{{ range.address }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                {{ range.location.coordinates[1].toFixed(6) }}, {{ range.location.coordinates[0].toFixed(6) }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-300 max-w-xs break-words">{{ range.notes || '-' }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                <a v-if="range.website" :href="range.website" target="_blank" class="text-blue-400 hover:underline">Linkki</a>
                <span v-else>N/A</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ range.phoneNumber || 'N/A' }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="md:hidden space-y-4">
        <div v-for="range in ranges" :key="range._id" class="bg-gray-800 p-4 rounded-lg shadow-md">
          <h3 class="text-lg font-semibold mb-2">{{ range.name }}</h3>
          <div class="text-sm text-gray-300 space-y-1">
            <p><span class="font-medium text-gray-400">Osoite:</span> {{ range.address }}</p>
            <p><span class="font-medium text-gray-400">Koordinaatit:</span> {{ range.location.coordinates[1].toFixed(6) }}, {{ range.location.coordinates[0].toFixed(6) }}</p>
            <p v-if="range.website"><span class="font-medium text-gray-400">Verkkosivusto:</span> <a :href="range.website" target="_blank" class="text-blue-400 hover:underline">Linkki</a></p>
            <p v-if="range.phoneNumber"><span class="font-medium text-gray-400">Puhelin:</span> {{ range.phoneNumber }}</p>
            <p v-if="range.notes"><span class="font-medium text-gray-400">Muistiinpanot:</span> {{ range.notes }}</p>
          </div>
        </div>
      </div>
    </div>

    <router-link
      to="/ranges/new"
      class="fixed right-8 bg-green-500 hover:bg-green-600 text-white p-4 rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-110 focus:outline-none bottom-24 md:bottom-8"
    >
      <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
      </svg>
    </router-link>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
// FIX: Import 'api' from '../services/api'
import api from '../services/api';
import { useApi } from '../composables/useApi';
// FIX: Remove direct axios import if not used elsewhere
// import axios from 'axios';

const ranges = ref([]);
const { loading, error, execute } = useApi();

const fetchRanges = async () => {
  console.log("[ShootingRangeList] Fetching ranges...");
  loading.value = true;
  try {
    // FIX: Use api.get instead of axios.get
    const responseData = await execute(api.get, '/api/ranges');
    ranges.value = responseData;
    console.log("[ShootingRangeList] Fetched ranges:", responseData);
  } catch (err) {
    console.error('[ShootingRangeList] Failed to fetch ranges:', err);
    error.value = err.message || 'Ampumaratojen lataaminen epäonnistui.';
  } finally {
    loading.value = false;
    console.log("[ShootingRangeList] Fetching finished.");
  }
};

onMounted(() => {
  console.log("[ShootingRangeList] Component mounted, calling fetchRanges.");
  fetchRanges();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
