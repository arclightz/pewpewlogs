<template>
  <nav class="bg-gray-800 p-4 shadow-md flex items-center justify-between w-full">
    <div class="flex items-center">
      <button @click="$emit('toggle-sidebar')" class="text-white focus:outline-none mr-4">
        <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
        </svg>
      </button>

      <router-link to="/" class="text-white text-2xl font-bold">Pewpewlogs</router-link>
    </div>

    <div class="flex items-center space-x-4">
      <template v-if="state.user">
        <span class="text-white text-sm hidden md:block">Hello, {{ state.user.name || state.user.email }}!</span>
        <button @click="handleLogout" class="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-3 rounded text-sm">
          Logout
        </button>
      </template>
      <template v-else>
        <router-link to="/login" class="text-white hover:text-blue-200 hidden md:block text-sm">Login</router-link>
        <router-link to="/register" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded text-sm hidden md:block">
          Register
        </router-link>
      </template>
    </div>
  </nav>
</template>

<script setup>
import { useRouter } from 'vue-router';
import state from '../services/state';
import authService from '../services/authService';

const router = useRouter();
const emit = defineEmits(['toggle-sidebar']); // Emit event to parent (App.vue)

const handleLogout = () => {
  authService.logout();
};
</script>

<style scoped>
/* No specific scoped styles needed here, mainly Tailwind classes */
</style>
