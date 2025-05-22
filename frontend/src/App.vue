<template>
  <div class="flex min-h-screen bg-gray-900 text-white">
    <SideBar :is-sidebar-open="isSidebarOpen" @toggle-sidebar="toggleSidebar" @close-sidebar="closeSidebar" />

    <div
      :class="{ 'ml-64': isSidebarOpen, 'ml-20': !isSidebarOpen }"
      class="flex-1 flex flex-col transition-all duration-300 ease-in-out"
    >
      <main class="flex-1 px-4 py-8 overflow-y-auto">
        <div v-if="isLoading" class="flex items-center justify-center h-full">
          <p>Loading application...</p>
        </div>
        <router-view v-else></router-view>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import SideBar from './components/SideBar.vue';
import state from './services/state';
import authService from './services/authService';
import { useRouter } from 'vue-router';

const router = useRouter();
const user = ref(null);
const isLoading = ref(true);
// Start with sidebar collapsed (false) as per the draft image
const isSidebarOpen = ref(false);

const isAuthenticated = computed(() => {
  return !!localStorage.getItem('token');
});

const checkAuthentication = async () => {
  try {
    const token = localStorage.getItem('token');
    if (token) {
      await authService.fetchCurrentUser();
      user.value = state.user;
    } else {
      state.user = null;
      user.value = null;
    }

    if (isAuthenticated.value && router.currentRoute.value.path === '/') {
       router.push('/dashboard');
    }
  } catch (error) {
    console.error('Error during authentication check:', error);
    localStorage.removeItem('token');
    state.user = null;
  } finally {
    isLoading.value = false;
  }
};

const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value;
};

const closeSidebar = () => {
  // Always close sidebar when a link is clicked, regardless of screen size
  // This is a common behavior for sidebars that expand/collapse
  isSidebarOpen.value = false;
};

onMounted(async () => {
  await checkAuthentication();
  // On mount, if on desktop, ensure sidebar starts collapsed as per draft
  // isSidebarOpen.value = window.innerWidth < 768 ? false : false; // Always start collapsed
});
</script>

<style scoped>
/* No specific scoped styles needed here, mainly Tailwind classes */
</style>
