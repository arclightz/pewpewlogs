<template>
  <div class="flex min-h-screen bg-gray-900 text-white">
    <SideBar v-if="!isMobile" :is-sidebar-open="isSidebarOpen" @close-sidebar="closeSidebar" />

    <div
      :class="{
        'ml-64': isSidebarOpen && !isMobile,     // Desktop: Sidebar open, push content
        'md:ml-20': !isSidebarOpen && !isMobile, // Desktop: Sidebar closed, subtle push
        'ml-0': isMobile                         // Mobile: No sidebar, no push
      }"
      class="flex-1 flex flex-col transition-all duration-300 ease-in-out"
    >
      <SideBar @toggle-sidebar="toggleSidebar" />

      <main class="flex-1 overflow-y-auto pb-16 md:pb-0"> <div v-if="isLoading" class="flex items-center justify-center h-full">
          <p>Loading application...</p>
        </div>
        <router-view v-else></router-view>
      </main>
    </div>

    <BottomNavBar v-if="isMobile" />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, onBeforeUnmount } from 'vue';
//import TopNavBar from './components/TopNavBar.vue';
import SideBar from './components/SideBar.vue';
import BottomNavBar from './components/BottomNavBar.vue';
import state from './services/state';
import authService from './services/authService';
import { useRouter } from 'vue-router';

const router = useRouter();
const user = ref(null);
const isLoading = ref(true);
const isSidebarOpen = ref(true); // Default to open on desktop
const isMobile = ref(false); // Reactive state to track mobile view

const isAuthenticated = computed(() => {
  return !!localStorage.getItem('token');
});

// Function to check if current view is mobile based on window width
const checkMobile = () => {
  // Tailwind's 'md' breakpoint is typically 768px
  isMobile.value = window.innerWidth < 768;
};

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
  isSidebarOpen.value = false;
};

onMounted(async () => {
  await checkAuthentication();
  checkMobile(); // Initial check on mount
  window.addEventListener('resize', checkMobile); // Add resize listener
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', checkMobile); // Clean up listener
});
</script>

<style scoped>
/* No specific scoped styles needed here, mainly Tailwind classes */
</style>
