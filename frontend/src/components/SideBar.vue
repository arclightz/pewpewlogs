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
        <li v-for="item in desktopMenuItems" :key="item.name">
          <router-link
            :to="item.path"
            class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white flex items-center rounded-lg"
            active-class="bg-blue-600 text-white"
            >
            <svg
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
        <div v-for="item in desktopBottomAuthItems" :key="item.name">
          <router-link
            v-if="item.path !== '/logout'"
            :to="item.path"
            class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white flex items-center rounded-lg mb-2"
            active-class="bg-blue-600 text-white"
          >
            <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon"></path>
            </svg>
            {{ item.name }}
          </router-link>
          <button
            v-else-if="item.action === 'logout'"
            @click="handleLogout"
            class="block w-full px-4 py-2 text-sm text-gray-300 hover:bg-red-700 hover:text-white text-left flex items-center rounded-lg"
          >
            <svg class="w-6 h-6 mr-2 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon"></path>
            </svg>
            {{ item.name }}
          </button>
        </div>
      </template>
      <template v-else>
        <router-link
          to="/login"
          class="block px-4 py-2 text-sm text-gray-300 hover:bg-blue-700 hover:text-white flex items-center rounded-lg mb-2"
          active-class="bg-blue-600 text-white"
          >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
          </svg>
          Kirjaudu sisään
        </router-link>
        <router-link
          to="/register"
          class="block px-4 py-2 text-sm text-gray-300 hover:bg-blue-700 hover:text-white flex items-center rounded-lg"
          active-class="bg-blue-600 text-white"
          >
          <svg class="w-6 h-6 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
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
// FIX: Import desktopMenuItems and desktopBottomAuthItems
import { desktopMenuItems, desktopBottomAuthItems } from '../constants/menuItems';

const props = defineProps({
  // isSidebarOpen is no longer a prop as sidebar is static
  // isSidebarOpen: {
  //   type: Boolean,
  //   required: true,
  // },
});

const emit = defineEmits([]); // No emits needed

const handleLogout = () => { // Renamed from handleLogoutAndCloseMenu
  authService.logout();
};

// FIX: Removed local menuItems definition
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
