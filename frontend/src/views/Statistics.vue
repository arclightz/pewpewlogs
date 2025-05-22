<template>
  <div class="container mx-auto px-4 py-8 text-white">
    <h1 class="text-3xl font-bold mb-6 text-center">Your Shooting Statistics</h1>

    <div v-if="loading" class="text-center text-lg">Loading statistics...</div>
    <div v-else-if="error" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ error }}</span>
    </div>
    <div v-else-if="!stats || (stats.overall.totalSessions === 0 && stats.shotsPerWeapon.length === 0)" class="text-center text-lg text-blue-200">
      <p>No statistics available yet. Log some sessions to see your progress!</p>
      <router-link to="/sessions/new" class="text-blue-400 hover:underline mt-4 block">Log your first session!</router-link>
    </div>
    <div v-else class="space-y-8">
      <div class="bg-blue-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4">Overall Performance</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <p class="text-blue-200">Total Sessions: <span class="font-bold text-white">{{ stats.overall.totalSessions }}</span></p>
          <p class="text-blue-200">Total Shots Fired: <span class="font-bold text-white">{{ stats.overall.totalShotsFired }}</span></p>
          <p class="text-blue-200">Total Hits: <span class="font-bold text-white">{{ stats.overall.totalHits }}</span></p>
          <p class="text-blue-200">Total Misses: <span class="font-bold text-white">{{ stats.overall.totalMisses }}</span></p>
          <p class="text-blue-200 col-span-full">Accuracy: <span class="font-bold text-white">{{ stats.overall.accuracyPercentage.toFixed(2) }}%</span></p>
        </div>
      </div>

      <div class="bg-blue-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4">Shots Per Weapon</h2>
        <div v-if="stats.shotsPerWeapon.length > 0" class="overflow-x-auto">
          <table class="min-w-full bg-blue-700 rounded-lg overflow-hidden">
            <thead>
              <tr>
                <th class="py-2 px-4 text-left text-blue-100">Weapon Name</th>
                <th class="py-2 px-4 text-left text-blue-100">Type</th>
                <th class="py-2 px-4 text-left text-blue-100">Total Shots</th>
                <th class="py-2 px-4 text-left text-blue-100">Sessions Used</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="weaponStat in stats.shotsPerWeapon" :key="weaponStat.weaponId" class="border-t border-blue-600">
                <td class="py-2 px-4">{{ weaponStat.weaponName || 'Unknown Weapon' }}</td>
                <td class="py-2 px-4">{{ weaponStat.weaponType || 'N/A' }}</td>
                <td class="py-2 px-4">{{ weaponStat.totalShots }}</td>
                <td class="py-2 px-4">{{ weaponStat.totalSessions }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <p v-else class="text-blue-200">No weapon usage data available.</p>
      </div>

      <div class="bg-blue-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4">Progress Over Time</h2>
        <p class="text-blue-200">(Graph and chart visualizations coming soon!)</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useStats } from '../composables/useStats'; // Import the stats composable

const { stats, loading, error, fetchStats } = useStats();

onMounted(() => {
  fetchStats(); // Fetch statistics when the component is mounted
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
