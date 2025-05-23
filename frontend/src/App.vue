<template>
  <div class="flex min-h-screen bg-gray-900 text-white">
    <SideBar v-if="!isMobile" />

    <div
      :class="{
        'ml-0': !isMobile, // Desktop: Always push content by sidebar's width
        'ml-0': isMobile    // Mobile: No sidebar, no push
      }"
      class="flex-1 flex flex-col transition-all duration-300 ease-in-out"
    >
      <main class="flex-1 overflow-y-auto pb-16 md:pb-0">
        <div v-if="isLoading" class="flex items-center justify-center h-full">
          <p>Ladataan sovellusta...</p>
        </div>
        <router-view v-else></router-view>
      </main>
    </div>

    <BottomNavBar v-if="isMobile" />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, onBeforeUnmount } from 'vue';
import SideBar from './components/SideBar.vue';
import BottomNavBar from './components/BottomNavBar.vue';
import state from './services/state';
import authService from './services/authService';
import { useRouter } from 'vue-router';

const router = useRouter();
const user = ref(null);
const isLoading = ref(true);
const isMobile = ref(false);

const isAuthenticated = computed(() => {
  return !!localStorage.getItem('token');
});

const checkMobile = () => {
  isMobile.value = window.innerWidth < 768;
};

const checkAuthentication = async () => {
  console.log("[App.vue] checkAuthentication started.");
  try {
    const token = localStorage.getItem('token');
    console.log(`[App.vue] Token found: ${!!token ? 'Present' : 'Absent'}`);
    if (token) {
      await authService.fetchCurrentUser();
      user.value = state.user;
      console.log(`[App.vue] state.user after fetch: ${!!state.user ? 'Populated' : 'Null'}`);
    } else {
      state.user = null;
      user.value = null;
      console.log("[App.vue] No token, state.user cleared.");
    }

    if (isAuthenticated.value && router.currentRoute.value.path === '/') {
       console.log("[App.vue] Authenticated on root, redirecting to dashboard.");
       router.push('/dashboard');
    }
  } catch (error) {
    console.error('[App.vue] Error during authentication check:', error);
    localStorage.removeItem('token');
    state.user = null;
  } finally {
    isLoading.value = false;
    console.log("[App.vue] checkAuthentication finished. isLoading set to false.");
  }
};

onMounted(async () => {
  console.log("[App.vue] Component mounted. Starting authentication check.");
  await checkAuthentication();
  checkMobile();
  window.addEventListener('resize', checkMobile);
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', checkMobile);
});
</script>

<style scoped>
/* No specific scoped styles needed here, mainly Tailwind classes */
</style>
