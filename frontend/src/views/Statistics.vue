<template>
  <div class="statistics">
    <h1>Statistics</h1>
    <div v-if="loading">Loading statistics...</div>
    <div v-else-if="error">Error loading statistics: {{ error }}</div>
    <div v-else>
      <h2>Overall Statistics</h2>
      <div class="stat-card">
        <div>Total Sessions: {{ overallStats.totalSessions }}</div>
        <div>Total Shots: {{ overallStats.totalShots }}</div>
        <div>Average Score: {{ overallStats.averageScore.toFixed(2) }}</div>
      </div>

      <h2>Weapon Statistics</h2>
      <div v-for="stat in weaponStats" :key="stat.weaponId" class="stat-card">
        <h3>{{ stat.weaponName }}</h3>
        <div>Total Sessions: {{ stat.totalSessions }}</div>
        <div>Total Shots: {{ stat.totalShots }}</div>
        <div>Average Score: {{ stat.averageScore.toFixed(2) }}</div>
      </div>

      <h2>Recent Sessions</h2>
      <div v-for="session in recentSessions" :key="session.id" class="session-card">
        <div>Date: {{ new Date(session.date).toLocaleDateString() }}</div>
        <div>Weapon: {{ session.weapon.name }}</div>
        <div>Score: {{ session.averageScore.toFixed(2) }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useStats } from '@/composables/useStats'

export default {
  setup() {
    const { getOverallStats, getWeaponStats, getRecentSessions } = useStats()
    const overallStats = ref({})
    const weaponStats = ref([])
    const recentSessions = ref([])
    const loading = ref(true)
    const error = ref(null)

    onMounted(async () => {
      try {
        [overallStats.value, weaponStats.value, recentSessions.value] = await Promise.all([
          getOverallStats(),
          getWeaponStats(),
          getRecentSessions()
        ])
      } catch (e) {
        error.value = e.message
      } finally {
        loading.value = false
      }
    })

    return { overallStats, weaponStats, recentSessions, loading, error }
  }
}
</script>

<style scoped>
.stat-card, .session-card {
  border: 1px solid #ddd;
  padding: 10px;
  margin-bottom: 10px;
  border-radius: 4px;
}
</style>