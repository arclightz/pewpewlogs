<template>
  <aside
    class="flex-shrink-0 h-screen bg-gray-800 text-white p-4 flex flex-col shadow-lg w-64 hidden md:flex"
  >
    <div class="flex items-center justify-center mb-8 h-12">
      <router-link to="/" class="text-white text-2xl font-bold">
        <svg width="50" height="50" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect width="200" height="200" fill="#1F2937"/>
            <g>
              <circle cx="100" cy="100" r="60" stroke="#3B82F6" stroke-width="6"/>
              <circle cx="100" cy="100" r="40" stroke="#3B82F6" stroke-width="6"/>
              <circle cx="100" cy="100" r="20" stroke="#3B82F6" stroke-width="6"/>
              <line x1="100" y1="40" x2="100" y2="160" stroke="#3B82F6" stroke-width="6"/>
              <line x1="40" y1="100" x2="160" y2="100" stroke="#3B82F6" stroke-width="6"/>
              <circle cx="115" cy="85" r="10" fill="#DC2626"/>
            </g>
        </svg>
      </router-link>
    </div>

    <nav class="mt-4 flex-grow overflow-y-auto">
      <ul>
        <li v-for="item in menuItems" :key="item.name">
          <router-link
            :to="item.path"
            class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white flex items-center rounded-lg"
            active-class="bg-blue-600 text-white"
            > <svg
              class="w-5 h-5 mr-3 flex-shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                :d="item.icon"
              ></path>
            </svg>
            {{ item.name }}
          </router-link>
        </li>
        </ul>
    </nav>

    <div class="mt-auto border-t border-gray-700 p-4">
      <template v-if="state.user">
        <router-link
          to="/profile"
          class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white flex items-center rounded-lg"
          active-class="bg-blue-600 text-white"
          > <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
          </svg>
          Profiili
        </router-link>

        <button
          @click="handleLogoutAndCloseMenu"
          class="block w-full px-4 py-2 text-sm text-gray-300 hover:bg-red-700 hover:text-white text-left flex items-center rounded-lg"
        >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          Kirjaudu ulos
        </button>
      </template>
      <template v-else>
        <router-link
          to="/login"
          class="block px-4 py-2 text-sm text-gray-300 hover:bg-blue-700 hover:text-white flex items-center rounded-lg mb-2"
          active-class="bg-blue-600 text-white"
          > <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          Kirjaudu sisään
        </router-link>
        <router-link
          to="/register"
          class="block px-4 py-2 text-sm text-gray-300 hover:bg-blue-700 hover:text-white flex items-center rounded-lg"
          active-class="bg-blue-600 text-white"
          > <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
          </svg>
          Rekisteröidy
        </router-link>
      </template>
    </div>
  </aside>
</template>

<script setup>
import { ref, defineProps, defineEmits } from 'vue';
import state from '../services/state';
import authService from '../services/authService';

const props = defineProps({
  // isSidebarOpen is no longer a prop as sidebar is static
  // isSidebarOpen: {
  //   type: Boolean,
  //   required: true,
  // },
});

// Emits are no longer needed as sidebar is static
const emit = defineEmits([]); // No emits needed

const handleLogoutAndCloseMenu = () => {
  authService.logout();
  // No close-sidebar emit needed
};

// Define the menuItems array with name, path, and icon (SVG path)
const menuItems = ref([
  {
    name: 'Ohjauspaneli',
    path: '/dashboard',
    icon: 'M2.5 3A1.5 1.5 0 0 0 1 4.5v4A1.5 1.5 0 0 0 2.5 10h6A1.5 1.5 0 0 0 10 8.5v-4A1.5 1.5 0 0 0 8.5 3h-6Zm11 2A1.5 1.5 0 0 0 12 6.5v7a1.5 1.5 0 0 0 1.5 1.5h4a1.5 1.5 0 0 0 1.5-1.5v-7A1.5 1.5 0 0 0 17.5 5h-4Zm-10 7A1.5 1.5 0 0 0 2 13.5v2A1.5 1.5 0 0 0 3.5 17h6a1.5 1.5 0 0 0 1.5-1.5v-2A1.5 1.5 0 0 0 9.5 12h-6Z',
  },
  {
    name: 'Päiväkirja',
    path: '/sessions',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01'
  },
  {
    name: 'Aseet',
    path: '/weapons',
    icon: 'M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4'
  },
  {
    name: 'Tilastot',
    path: '/statistics',
    icon: 'M11 3.055A9.001 9.001 0 1020.945 13H11V3.055zM20.488 9H15V3.512A9.025 9.025 0 0120.488 9z'
  },
  {
    name: 'Ampumaradat',
    path: '/ranges',
    icon: 'M8.157 2.176a1.5 1.5 0 0 0-1.147 0l-4.084 1.69A1.5 1.5 0 0 0 2 5.25v10.877a1.5 1.5 0 0 0 2.074 1.386l3.51-1.452 4.26 1.762a1.5 1.5 0 0 0 1.146 0l4.083-1.69A1.5 1.5 0 0 0 18 14.75V3.872a1.5 1.5 0 0 0-2.073-1.386l-3.51 1.452-4.26-1.762ZM7.58 5a.75.75 0 0 1 .75.75v6.5a.75.75 0 0 1-1.5 0v-6.5A.75.75 0 0 1 7.58 5Zm5.59 2.75a.75.75 0 0 0-1.5 0v6.5a.75.75 0 0 0 1.5 0v-6.5Z'
  },
]);
</script>

<style scoped>
/* Base styles for the sidebar */
aside {
  width: 16rem; /* 256px */
}

/* Ensure the active link has a distinct color */
.router-link-active {
  background-color: #3b82f6; /* A slightly lighter blue for active link */
  color: white;
}
</style>
