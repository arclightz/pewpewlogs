<template>
  <nav class="fixed bottom-0 left-0 w-full bg-gray-800 text-white shadow-lg p-3 md:hidden z-30">
    <div class="flex justify-around items-center h-full">
      <router-link
        v-for="item in menuItems"
        :key="item.name"
        :to="item.path"
        class="flex flex-col items-center justify-center text-xs text-white hover:text-blue-400 p-1 rounded-lg"
        active-class="text-blue-400"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon"></path>
        </svg>
        <span>{{ item.name }}</span>
      </router-link>

      <template v-if="state.user">
        <router-link to="/profile" class="flex flex-col items-center justify-center text-xs text-white hover:text-blue-400 p-1 rounded-lg" active-class="text-blue-400">
          <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
          </svg>
          <span>Profiili</span>
        </router-link>
        <button @click="handleLogout" class="flex flex-col items-center justify-center text-xs text-white hover:text-red-400 p-1 rounded-lg">
          <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          <span>Kirjaudu ulos</span>
        </button>
      </template>
      <template v-else>
        <router-link to="/login" class="flex flex-col items-center justify-center text-xs text-white hover:text-blue-400 p-1 rounded-lg" active-class="text-blue-400">
          <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          <span>Kirjaudu sisään</span>
        </router-link>
      </template>
    </div>
  </nav>
</template>

<script setup>
import { ref } from 'vue'; // Import ref for menuItems
import state from '../services/state';
import authService from '../services/authService';
import { useRouter } from 'vue-router'; // Import router for logout redirect

const router = useRouter(); // Initialize router

// Define the menuItems array with name, path, and icon (SVG path)
const menuItems = ref([
  {
    name: 'Ohjauspaneli',
    path: '/dashboard',
    icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2 2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6' // Dashboard/Home icon
  },
  {
    name: 'Päiväkirja',
    path: '/sessions',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01' // Document/Sessions icon
  },
  {
    name: 'Aseet',
    path: '/weapons',
    icon: 'M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4' // Weapons icon
  },
  {
    name: 'Tilastot',
    path: '/statistics',
    icon: 'M11 3.055A9.001 9.001 0 1020.945 13H11V3.055zM20.488 9H15V3.512A9.025 9.025 0 0120.488 9z' // Statistics icon
  },
  {
    name: 'Ampumaradat',
    path: '/ranges',
    icon: 'M3.055 11.25a8.15 8.15 0 0115.89 0m-16.79 0a8.15 8.15 0 0015.89 0m-16.79 0H3.21a.75.75 0 01-.75-.75V8.25a.75.75 0 01.75-.75h16.5a.75.75 0 01.75.75v2.25a.75.75 0 01-.75.75h-.045a8.15 8.15 0 00-15.89 0z' // Location icon (or range-like icon)
  }
]);

const handleLogout = () => {
  authService.logout();
  // router.push('/login'); // authService.logout() already handles this redirect
};
</script>

<style scoped>
/* Ensure active link has a distinct color */
.router-link-active {
  color: #60a5fa; /* A lighter blue for active link */
}
</style>
