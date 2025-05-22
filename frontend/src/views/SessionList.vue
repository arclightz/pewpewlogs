<template>
  <div class="container mx-auto px-4 py-8 text-white">
    <h1 class="text-3xl font-bold mb-6 text-center">Your Shooting Sessions</h1>

    <div v-if="loading" class="text-center text-lg">Loading sessions...</div>
    <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ error }}</span>
    </div>
    <div v-else-if="sessions.length === 0" class="text-center text-lg text-blue-200">
      <p>No sessions logged yet.</p>
      <router-link to="/sessions/new" class="text-blue-400 hover:underline mt-4 block">Log your first session!</router-link>
    </div>
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="session in sessions" :key="session._id" class="bg-blue-800 p-6 rounded-lg shadow-md">
        <h3 class="text-xl font-semibold mb-2">{{ new Date(session.date).toLocaleDateString() }} - {{ session.location }}</h3>
        <p class="text-blue-200 mb-1">Weapon: {{ session.weapon?.name || 'N/A' }}</p>
        <p class="text-blue-200 mb-1">Shots Fired: {{ session.numberOfShotsFired || 0 }}</p>
        <p class="text-blue-200">Distance: {{ session.distanceToTarget || 'N/A' }}</p>
        <div class="mt-4 flex justify-end">
          <!-- <router-link :to="`/sessions/${session._id}`" class="bg-blue-600 hover:bg-blue-700 text-white py-1 px-3 rounded text-sm">
            View Details
          </router-link> -->
        </div>
      </div>
    </div>

    <div class="mt-8 text-center">
      <router-link
        to="/sessions/new"
        class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
      >
        Log New Session
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useSessions } from '../composables/useSessions'; // Import the session composable

const { sessions, loading, error, fetchSessions } = useSessions();

onMounted(() => {
  fetchSessions(); // Fetch sessions when the component is mounted
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
