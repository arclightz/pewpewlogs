<template>
  <aside
    :class="{ 'w-64': isSidebarOpen, 'w-16': !isSidebarOpen }"
    class="fixed top-0 left-0 h-full bg-gray-800 text-white p-4 flex flex-col transition-all duration-150 ease-in-out z-20 shadow-lg"
  >
    <div class="flex items-center justify-center mb-8 h-12">
      <button @click="$emit('toggle-sidebar')" class="text-white focus:outline-none">
        <svg v-if="!isSidebarOpen" class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
        </svg>
        <svg v-else class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </button>
    </div>

    <nav class="flex flex-col space-y-4 flex-grow overflow-hidden">
      <router-link
        to="/dashboard"
        class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 whitespace-nowrap"
        @click="$emit('close-sidebar')"
      >
        <svg class="['w-6 h-6 mr-3 flex-shrink-0', { 'hidden': !isSidebarOpen }]" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2 2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
        </svg>
        <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Dashboard</span>
      </router-link>

      <router-link
        to="/sessions"
        class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 whitespace-nowrap"
        @click="$emit('close-sidebar')"
      >
        <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path>
        </svg>
        <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Sessions</span>
      </router-link>

      <router-link
        to="/weapons"
        class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 whitespace-nowrap"
        @click="$emit('close-sidebar')"
      >
        <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
        </svg>
        <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Weapons</span>
      </router-link>

      <router-link
        to="/statistics"
        class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 whitespace-nowrap"
        @click="$emit('close-sidebar')"
      >
        <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z"></path>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"></path>
        </svg>
        <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Statistics</span>
      </router-link>
    </nav>

    <div class="mt-auto pt-4 border-t border-gray-700 overflow-hidden">
      <template v-if="state.user">
        <router-link
          to="/profile"
          class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 mb-2 whitespace-nowrap"
          @click="$emit('close-sidebar')"
        >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
          </svg>
          <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Profile</span>
        </router-link>

        <button
          @click="handleLogoutAndCloseMenu"
          class="flex items-center p-2 rounded-lg hover:bg-red-700 transition-colors duration-200 w-full text-left whitespace-nowrap"
        >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Logout</span>
        </button>
      </template>
      <template v-else>
        <router-link
          to="/login"
          class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 mb-2 whitespace-nowrap"
          @click="$emit('close-sidebar')"
        >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Login</span>
        </router-link>
        <router-link
          to="/register"
          class="flex items-center p-2 rounded-lg hover:bg-blue-700 transition-colors duration-200 whitespace-nowrap"
          @click="$emit('close-sidebar')"
        >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
          </svg>
          <span :class="{'hidden': !isSidebarOpen}" class="text-lg">Register</span>
        </router-link>
      </template>
    </div>
  </aside>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';
import state from '../services/state';
import authService from '../services/authService';

const props = defineProps({
  isSidebarOpen: {
    type: Boolean,
    required: true,
  },
});

const emit = defineEmits(['toggle-sidebar', 'close-sidebar']); // Added toggle-sidebar emit

const handleLogoutAndCloseMenu = () => {
  authService.logout();
  emit('close-sidebar');
};
</script>

<style scoped>
/* Base styles for the sidebar */
aside {
  /* Default width for expanded state 
  width: 16rem; 256px */
}

/* Styles for collapsed state on desktop */
/* The transition for width is handled by the main class on aside */
/* For the collapsed state, ensure text is hidden and icons remain */
.router-link-active {
  background-color: #3b82f6; /* A slightly lighter blue for active link */
  color: white;
}
</style>
