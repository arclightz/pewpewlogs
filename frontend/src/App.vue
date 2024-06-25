<!-- App.vue -->
<template>
  <div id="app">
    <nav v-if="isAuthenticated">
      <router-link to="/dashboard">Dashboard</router-link>
      <router-link to="/sessions">Sessions</router-link>
      <router-link to="/weapons">Weapons</router-link>
      <router-link to="/stats">Statistics</router-link>
      <button @click="logout">Logout</button>
    </nav>
    <router-view></router-view>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useKindeAuth } from '@kinde-oss/kinde-auth-vue'

export default {
  setup() {
    const { isAuthenticated, login, logout, getToken } = useKindeAuth()

    onMounted(async () => {
      // Check if we're handling a redirect from Kinde
      await handleRedirect()
    })

    const handleRedirect = async () => {
      if (window.location.search.includes("code=")) {
        try {
          await getToken()
          // Redirect to dashboard after successful login
          window.location.href = '/dashboard'
        } catch (error) {
          console.error('Authentication error:', error)
        }
      }
    }

    return { isAuthenticated, login, logout }
  }
}
</script>