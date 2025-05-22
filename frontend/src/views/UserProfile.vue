<template>
  <div class="flex flex-col items-center justify-center min-h-[calc(100vh-80px)] text-white px-4">
    <div class="bg-blue-800 p-8 rounded-lg shadow-xl w-full max-w-md">
      <h2 class="text-3xl font-bold mb-6 text-center">User Profile</h2>

      <div v-if="state.user" class="space-y-4">
        <div class="flex items-center">
          <strong class="w-24 text-blue-200">Name:</strong>
          <span class="text-xl">{{ state.user.name }}</span>
        </div>
        <div class="flex items-center">
          <strong class="w-24 text-blue-200">Email:</strong>
          <span class="text-xl">{{ state.user.email }}</span>
        </div>
        </div>
      <div v-else class="text-center text-lg text-blue-200">
        <p>User data not available. Please log in.</p>
        <router-link to="/login" class="text-blue-400 hover:underline mt-4 block">Go to Login</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import state from '../services/state'; // Import global state to access user data
</script>

<style scoped>
/* Scoped styles for this component */
</style>
