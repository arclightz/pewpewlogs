<template>
  <nav class="bg-blue-800 p-4 shadow-md">
    <div class="container mx-auto flex justify-between items-center">
      <router-link to="/" class="text-white text-2xl font-bold">Pewpewlogs</router-link>

      <div class="space-x-4">
        <router-link to="/dashboard" class="text-white hover:text-blue-200">Dashboard</router-link>
        <router-link to="/sessions" class="text-white hover:text-blue-200">Sessions</router-link>
        <router-link to="/weapons" class="text-white hover:text-blue-200">Weapons</router-link>
        <router-link to="/statistics" class="text-white hover:text-blue-200">Statistics</router-link>
      </div>

      <div class="flex items-center space-x-4">
        <template v-if="state.user">
          <span class="text-white">Hello, {{ state.user.name || state.user.email }}!</span>
          <router-link to="/profile" class="text-white hover:text-blue-200">Profile</router-link>
          <button @click="handleLogout" class="bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-3 rounded">
            Logout
          </button>
        </template>
        <template v-else>
          <router-link to="/login" class="text-white hover:text-blue-200">Login</router-link>
          <router-link to="/register" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-1 px-3 rounded">
            Register
          </router-link>
        </template>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRouter } from 'vue-router';
import state from '../services/state'; // Import your global state
import authService from '../services/authService'; // Import your authService

const router = useRouter();

const handleLogout = () => {
  authService.logout(); // Call the logout method from your authService
};
</script>

<style scoped>
/* Add any component-specific styles here if needed */
</style>
