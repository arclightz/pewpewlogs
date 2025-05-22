<template>
  <div class="min-h-[calc(100vh-80px)] flex flex-col items-center justify-center text-white px-4">
    <h1 class="text-4xl font-bold mb-6">Welcome to Your Dashboard, {{ state.user?.name || state.user?.email || 'User' }}!</h1>
    <p class="text-lg mb-8 text-center">
      Here you can quickly access your shooting sessions, manage your weapons, and view your statistics.
    </p>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 w-full max-w-4xl">
      <router-link
        to="/sessions"
        class="bg-blue-700 hover:bg-blue-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
        </svg>
        <span class="text-xl font-semibold">View Sessions</span>
      </router-link>

      <router-link
        to="/sessions/new"
        class="bg-green-700 hover:bg-green-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-xl font-semibold">Log New Session</span>
      </router-link>

      <router-link
        to="/weapons"
        class="bg-purple-700 hover:bg-purple-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10m-4-2h8m-4 2v4"></path>
        </svg>
        <span class="text-xl font-semibold">Manage Weapons</span>
      </router-link>

      <router-link
        to="/statistics"
        class="bg-yellow-700 hover:bg-yellow-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z"></path>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"></path>
        </svg>
        <span class="text-xl font-semibold">View Statistics</span>
      </router-link>

      <router-link
        to="/profile"
        class="bg-indigo-700 hover:bg-indigo-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
        </svg>
        <span class="text-xl font-semibold">My Profile</span>
      </router-link>
    </div>
  </div>
</template>

<script setup>
import state from '../services/state'; // Import global state to display user name
</script>

<style scoped>
/* Scoped styles for this component */
</style>
