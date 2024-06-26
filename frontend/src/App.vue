<!--
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
-->
<template>
  <div class="min-h-screen bg-blue-900 text-white">
    <TopNavBar />
    <main class="container mx-auto px-4 py-8">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { getUser, handleCallback } from "./services/authService";
import TopNavBar from './components/TopNavBar.vue';

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
</script>
