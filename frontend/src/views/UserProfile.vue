<template>
  <div class="px-4 py-8 min-h-screen">
    <h1 class="text-3xl font-bold mb-6">User Profile</h1>

    <div v-if="state.user" class="space-y-8">
      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4">Account Information</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="flex items-center">
            <strong class="w-24 text-blue-200">Name:</strong>
            <span class="text-xl">{{ state.user.name }}</span>
          </div>
          <div class="flex items-center">
            <strong class="w-24 text-blue-200">Email:</strong>
            <span class="text-xl">{{ state.user.email }}</span>
          </div>
          </div>
      </div>

      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4">Sessions Overview</h2>
        <div v-if="sessionsLoading" class="text-blue-200">Loading session data...</div>
        <div v-else-if="sessionsError" class="text-red-400">Error loading sessions: {{ sessionsError }}</div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
          <div>
            <p class="text-blue-200">Total Sessions: <span class="font-bold text-white">{{ sessions.length }}</span></p>
            <p class="text-blue-200" v-if="timeSinceLastSession">Time since last session: <span class="font-bold text-white">{{ timeSinceLastSession }}</span></p>
            <p class="text-blue-200" v-else>No sessions logged yet.</p>
          </div>
          <div class="md:text-right">
            <router-link
              to="/sessions"
              class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
            >
              Go to Sessions
            </router-link>
          </div>
        </div>
      </div>

      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4">Weapons Inventory</h2>
        <div v-if="weaponsLoading" class="text-blue-200">Loading weapon data...</div>
        <div v-else-if="weaponsError" class="text-red-400">Error loading weapons: {{ weaponsError }}</div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
          <p class="text-blue-200">Total Weapons: <span class="font-bold text-white">{{ weapons.length }}</span></p>
          <div class="md:text-right">
            <router-link
              to="/weapons"
              class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
            >
              Go to Weapon Inventory
            </router-link>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="text-center text-lg text-blue-200 mt-10">
      <p>User data not available. Please log in to view your profile.</p>
      <router-link to="/login" class="text-blue-400 hover:underline mt-4 block">Go to Login</router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import state from '../services/state';
import { useSessions } from '../composables/useSessions'; // Import useSessions composable
import { useWeapons } from '../composables/useWeapons'; // Import useWeapons composable

const { sessions, loading: sessionsLoading, error: sessionsError, fetchSessions } = useSessions();
const { weapons, loading: weaponsLoading, error: weaponsError, fetchWeapons } = useWeapons();

// Computed property to calculate time since last session
const timeSinceLastSession = computed(() => {
  if (sessions.value.length === 0) {
    return null;
  }
  // Sessions are fetched sorted by date: -1 (latest first), so the first one is the last session
  const lastSessionDate = new Date(sessions.value[0].date);
  const now = new Date();
  const diffTime = Math.abs(now - lastSessionDate);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return '1 day ago';
  return `${diffDays} days ago`;
});

onMounted(() => {
  fetchSessions(); // Fetch sessions to get last session date and count
  fetchWeapons(); // Fetch weapons to get total count
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
