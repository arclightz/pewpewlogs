<template>
  <div class="px-4 py-8 relative min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Harjoituspäiväkirja</h1>
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

    <div v-if="loading" class="text-center text-lg">Loading sessions...</div>
    <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ error }}</span>
    </div>
<div v-else>
      <div class="hidden md:block overflow-x-auto bg-gray-800 rounded-lg shadow-lg">
        <table class="min-w-full divide-y divide-gray-700">
          <thead class="bg-blue-700">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Kirjausaika</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Sijainti</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Ase</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Ammutut laukaukset</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Hits/Misses</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Matka</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-blue-100 uppercase tracking-wider">Kommentit</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-700">
            <tr v-for="session in sessions" :key="session._id" class="hover:bg-gray-700 transition-colors duration-200">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ new Date(session.date).toLocaleDateString('fi-FI') }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.location }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.weapon?.name || 'N/A' }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.numberOfShotsFired || 0 }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.hits || 0 }} / {{ session.misses || 0 }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.distanceToTarget || 'N/A' }}m</td>
              <td class="px-6 py-4 text-sm text-gray-300 max-w-xs">{{ session.notes || '-' }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="md:hidden space-y-4">
        <div v-for="session in sessions" :key="session._id" class="bg-gray-800 p-4 rounded-lg shadow-md">
          <div class="flex justify-between items-center mb-2">
            <h3 class="text-lg font-semibold">{{ new Date(session.date).toLocaleDateString('fi-FI') }}</h3>
            <span class="text-blue-300 text-sm">{{ session.location }}</span>
          </div>
          <div class="text-sm text-gray-300 space-y-1">
            <p><span class="font-medium text-gray-400">Ase:</span> {{ session.weapon?.name || 'N/A' }} ({{ session.weapon?.type || 'N/A' }})</p>
            <p><span class="font-medium text-gray-400">Ammutut laukaukset:</span> {{ session.numberOfShotsFired || 0 }}</p>
            <p><span class="font-medium text-gray-400">Hits/Misses:</span> {{ session.hits || 0 }} / {{ session.misses || 0 }}</p>
            <p><span class="font-medium text-gray-400">Matka:</span> {{ session.distanceToTarget || 'N/A' }}m</p>
            <p v-if="session.notes"><span class="font-medium text-gray-400">Kommentit:</span> {{ session.notes }}</p>
          </div>
        </div>
      </div>
    </div>

    <router-link
      to="/sessions/new"
      class="fixed right-8 bg-green-500 hover:bg-green-600 text-white p-4 rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-110 focus:outline-none bottom-24 md:bottom-8"
    >
      <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
      </svg>
    </router-link>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useSessions } from '../composables/useSessions';

const { sessions, loading, error, fetchSessions } = useSessions();

onMounted(() => {
  fetchSessions();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
