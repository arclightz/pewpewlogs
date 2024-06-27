<template>
  <div class="min-h-screen bg-blue-900 text-white">
    <TopNavBar v-if="isAuthenticated"/>
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
