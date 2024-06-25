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
import { ref, onMounted } from 'vue';
import { login, logout, getUser, handleCallback } from "./services/authService";

export default {
  setup() {
    const isAuthenticated = ref(false);

    const checkAuthentication = async () => {
      const user = await getUser();
      isAuthenticated.value = !!user;
      if (user && window.location.search.includes("code=")) {
        window.location.href = '/dashboard';
      }
    };

    onMounted(async () => {
      // Check if we're handling a redirect from OIDC
      if (window.location.search.includes("code=")) {
        try {
          await handleCallback();
          await checkAuthentication();
        } catch (error) {
          console.error('Authentication error:', error);
        }
      } else {
        await checkAuthentication();
      }
    });

    return { isAuthenticated, login, logout };
  }
};
</script>
