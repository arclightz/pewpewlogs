<template>
  <div class="flex flex-col items-center justify-center min-h-[calc(100vh-80px)] text-white text-center px-4">
    <h1 class="text-5xl font-extrabold mb-6">Welcome to Pewpewlogs!</h1>
    <p class="text-xl mb-8 max-w-2xl">
      Your ultimate companion for tracking, analyzing, and improving your shooting performance.
      Log your sessions, track your shots, and visualize your progress.
    </p>
    <div class="space-x-4">
      <router-link
        to="/register"
        class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
      >
        Get Started
      </router-link>
      <router-link
        to="/login"
        class="bg-gray-700 hover:bg-gray-600 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
      >
        Login
      </router-link>
    </div>
  </div>
</template>

<script setup>
// No specific logic needed here for the landing page beyond navigation.
</script>

<style scoped>
/* Scoped styles for this component */
</style>
