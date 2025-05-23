<template>
  <aside
    class="fixed inset-y-0 left-0 z-30 w-64 bg-gray-800 text-white transition-transform transform flex flex-col"
    :class="{
      'translate-x-0': isSidebarOpen, // Visible when open
      '-translate-x-full': !isSidebarOpen, // Hidden (off-screen) when closed
      'lg:translate-x-0': true // Always visible on large screens (overrides -translate-x-full)
    }"
    @click.stop="() => {}"
  >
    <div class="flex items-center justify-between p-4">
      <router-link to="/" class="text-2xl font-bold">
        <svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
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
      <button @click="$emit('close-sidebar')" class="text-white focus:outline-none lg:hidden">
        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
      </button>
    </div>

    <nav class="mt-4 flex-grow overflow-y-auto">
      <ul>
        <li v-for="item in menuItems" :key="item.name">
          <router-link
            :to="item.path"
            class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white flex items-center"
            active-class="bg-blue-600 text-white"
            @click="$emit('close-sidebar')"
          >
            <svg
              class="w-5 h-5 mr-3"
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
      <router-link
        to="/profile"
        class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white flex items-center"
        active-class="bg-blue-600 text-white"
        @click="$emit('close-sidebar')"
      >
        My Profile
      </router-link>
      <button
        @click="handleLogoutAndCloseMenu"
        class="block w-full px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-white text-left flex items-center"
      >
        Logout
      </button>
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

const emit = defineEmits(['close-sidebar', 'logout']); // Explicitly define emitted events

// Example menu items (you'll replace this with your actual data)
const menuItems = [
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
];

const handleLogoutAndCloseMenu = () => {
  authService.logout();
  emit('close-sidebar'); // Close sidebar after logout
};
</script>

<style scoped>
/* No specific scoped styles needed if using Tailwind's active-class */
</style>