<template>
  <div class="px-4 py-8 relative min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Ampumaistuntosi</h1>
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

    <div v-if="loading" class="text-center text-lg text-gray-300">Ladataan istuntoja...</div>
    <div v-else-if="error" class="bg-red-800 text-white px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">Virhe istuntojen latauksessa: {{ error }}</span>
    </div>
    <div v-else-if="sessions.length === 0" class="text-center text-lg text-gray-300 mt-10">
      <p>Ei istuntoja kirjattu vielä.</p>
      <p class="mt-2">Napsauta '+' -painiketta kirjataksiasi ensimmäisen istunnon!</p>
    </div>
    <div v-else>
      <div class="hidden md:block overflow-x-auto bg-gray-800 rounded-lg shadow-lg">
        <table class="min-w-full divide-y divide-gray-700">
          <thead class="bg-gray-700">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider"></th> <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Pvm</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Tyyppi</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Laji</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Ampumarata</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Ase</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Laukauksia</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-700">
            <template v-for="session in sessions" :key="session._id">
              <tr class="hover:bg-gray-700 transition-colors duration-200">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  <button @click="toggleDetails(session._id)" class="text-blue-400 hover:text-blue-300 focus:outline-none">
                    <svg class="w-5 h-5 transform transition-transform duration-200" :class="{'rotate-90': expandedSessions.has(session._id)}" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5" xmlns="http://www.w3.org/2000/svg">
                      <path stroke-linecap="round" stroke-linejoin="round" :d="SVG_ICONS.expand" />
                    </svg>
                  </button>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ new Date(session.date).toLocaleDateString('fi-FI') }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.type || 'N/A' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.sportType || 'N/A' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.range?.name || 'N/A' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.weapon?.name || 'N/A' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ session.numberOfShotsFired || 0 }}</td>
              </tr>
              <tr v-if="expandedSessions.has(session._id)" class="bg-gray-700">
                <td :colspan="tableColumnCount" class="p-4">
                  <div class="bg-gray-900 p-4 rounded-lg shadow-inner space-y-2 text-sm text-gray-300">
                    <p v-if="session.weather"><span class="font-medium text-gray-400">Sää:</span> {{ session.weather }}</p>
                    <p v-if="session.ammunitionType"><span class="font-medium text-gray-400">Ammustyyppi:</span> {{ session.ammunitionType }} ({{ session.ammunitionCount || 0 }})</p>
                    <p v-if="session.result"><span class="font-medium text-gray-400">Tulos:</span> {{ session.result }}</p>
                    <p v-if="session.hitFactor"><span class="font-medium text-gray-400">Hit Factor:</span> {{ session.hitFactor }}</p>
                    <p v-if="session.compScore"><span class="font-medium text-gray-400">Kilpailutulos (%):</span> {{ session.compScore }}%</p>
                    <p v-if="session.distanceToTarget"><span class="font-medium text-gray-400">Etäisyys:</span> {{ session.distanceToTarget }}m</p>
                    <p v-if="session.role"><span class="font-medium text-gray-400">Rooli:</span> {{ session.role }}</p>
                    <p v-if="session.notes"><span class="font-medium text-gray-400">Muistiinpanot:</span> {{ session.notes }}</p>
                    <p v-if="session.photos && session.photos.length > 0"><span class="font-medium text-gray-400">Kuvat:</span> ({{ session.photos.length }} kuvaa)</p>
                    <p v-if="session.signature"><span class="font-medium text-gray-400">Allekirjoitus:</span> (Näytä allekirjoitus)</p>
                  </div>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>

      <div class="md:hidden space-y-4">
        <div v-for="session in sessions" :key="session._id" class="bg-gray-800 p-4 rounded-lg shadow-md">
          <div class="flex justify-between items-center mb-2">
            <h3 class="text-lg font-semibold">{{ new Date(session.date).toLocaleDateString('fi-FI') }} - {{ session.type || 'N/A' }}</h3>
            <span class="text-gray-300 text-sm">{{ session.sportType || 'N/A' }}</span>
          </div>
          <div class="text-sm text-gray-300 space-y-1">
            <p><span class="font-medium text-gray-400">Ampumarata:</span> {{ session.range?.name || 'N/A' }}</p>
            <p><span class="font-medium text-gray-400">Ase:</span> {{ session.weapon?.name || 'N/A' }} ({{ session.weapon?.type || 'N/A' }})</p>
            <p><span class="font-medium text-gray-400">Laukauksia:</span> {{ session.numberOfShotsFired || 0 }}</p>
          </div>
          <div class="mt-3 border-t border-gray-700 pt-3">
            <button @click="toggleDetails(session._id)" class="w-full text-left font-semibold text-blue-400 hover:text-blue-300 focus:outline-none">
              {{ expandedSessions.has(session._id) ? 'Piilota tiedot' : 'Näytä lisätiedot' }}
              <svg class="inline-block w-4 h-4 ml-2 transform transition-transform duration-200" :class="{'rotate-90': expandedSessions.has(session._id)}" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" :d="SVG_ICONS.expand" />
              </svg>
            </button>
            <div v-if="expandedSessions.has(session._id)" class="space-y-1 mt-2">
              <p v-if="session.weather"><span class="font-medium text-gray-400">Sää:</span> {{ session.weather }}</p>
              <p v-if="session.ammunitionType"><span class="font-medium text-gray-400">Ammustyyppi:</span> {{ session.ammunitionType }} ({{ session.ammunitionCount || 0 }})</p>
              <p v-if="session.result"><span class="font-medium text-gray-400">Tulos:</span> {{ session.result }}</p>
              <p v-if="session.hitFactor"><span class="font-medium text-gray-400">Hit Factor:</span> {{ session.hitFactor }}</p>
              <p v-if="session.compScore"><span class="font-medium text-gray-400">Kilpailutulos (%):</span> {{ session.compScore }}%</p>
              <p v-if="session.distanceToTarget"><span class="font-medium text-gray-400">Etäisyys:</span> {{ session.distanceToTarget }}m</p>
              <p v-if="session.role"><span class="font-medium text-gray-400">Rooli:</span> {{ session.role }}</p>
              <p v-if="session.notes"><span class="font-medium text-gray-400">Muistiinpanot:</span> {{ session.notes }}</p>
              <p v-if="session.photos && session.photos.length > 0"><span class="font-medium text-gray-400">Kuvat:</span> ({{ session.photos.length }} kuvaa)</p>
              <p v-if="session.signature"><span class="font-medium text-gray-400">Allekirjoitus:</span> (Näytä allekirjoitus)</p>
            </div>
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
import { ref, onMounted, computed } from 'vue';
import { useSessions } from '../composables/useSessions';
import { SVG_ICONS } from '../constants/menuItems'; // IMPORTANT: Import SVG_ICONS

const { sessions, loading, error, fetchSessions } = useSessions();

// State to manage expanded session details
const expandedSessions = ref(new Set());

// Computed property for table column count for colspan
const tableColumnCount = computed(() => {
  // Count the number of <th> elements in the desktop table header
  // This needs to be manually kept in sync with the template
  return 7; // Expand icon + 6 mandatory fields
});


const toggleDetails = (sessionId) => {
  if (expandedSessions.value.has(sessionId)) {
    expandedSessions.value.delete(sessionId);
  } else {
    expandedSessions.value.add(sessionId);
  }
  // Force reactivity update for Set
  expandedSessions.value = new Set(expandedSessions.value);
};

onMounted(() => {
  fetchSessions();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
