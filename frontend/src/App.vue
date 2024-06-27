<template>
  <div class="min-h-screen bg-blue-900 text-white">
    <TopNavBar />
    <main class="container mx-auto px-4 py-8">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { getUser, handleCallback } from "./services/kinde";
import TopNavBar from './components/TopNavBar.vue';
import state from './services/state';
import { useRouter } from 'vue-router';

const router = useRouter();
const user = ref(null);

const isAuthenticated = computed(() => !!user.value);

const checkAuthentication = async () => {
  const currentUser = await getUser();
  state.user = currentUser;
  if (currentUser && window.location.search.includes("code=")) {
    router.push('/dashboard');
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
