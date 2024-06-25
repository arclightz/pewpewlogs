<template>
    <div>
      <h1>Welcome to PewPewLogs</h1>
      <div v-if="user">
        <p>Hello, {{ user.given_name }}</p>
        <div class="stats" v-if="stats">
          <div>Total Sessions: {{ stats.totalSessions }}</div>
          <div>Average Score: {{ stats.averageScore }}</div>
        </div>
        <div class="quick-links">
          <router-link to="/sessions/new">New Session</router-link>
          <router-link to="/weapons">Manage Weapons</router-link>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import { ref, onMounted } from 'vue'
  import { useStats } from '../composables/useStats'
  
  export default {
  setup() {
    const user = ref(null);
    const stats = ref(null);
    const { getOverallStats } = useStats();

    onMounted(async () => {
      user.value = await getUser();
      if (user.value) {
        stats.value = await getOverallStats();
      }
    });

    return { user, stats };
  }
};
  </script>