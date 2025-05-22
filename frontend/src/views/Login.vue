<template>
  <div class="flex items-center justify-center min-h-screen bg-blue-900">
    <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md text-gray-800">
      <h2 class="text-2xl font-bold mb-6 text-center">Login to Pewpewlogs</h2>

      <form @submit.prevent="handleLogin">
        <div class="mb-4">
          <label for="email" class="block text-gray-700 text-sm font-bold mb-2">Email:</label>
          <input
            type="email"
            id="email"
            v-model="email"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            required
          />
        </div>
        <div class="mb-6">
          <label for="password" class="block text-gray-700 text-sm font-bold mb-2">Password:</label>
          <input
            type="password"
            id="password"
            v-model="password"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline"
            required
          />
        </div>
        <div v-if="errorMessage" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
          <span class="block sm:inline">{{ errorMessage }}</span>
        </div>
        <div class="flex items-center justify-between">
          <button
            type="submit"
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full"
            :disabled="isLoggingIn"
          >
            {{ isLoggingIn ? 'Logging In...' : 'Login' }}
          </button>
        </div>
      </form>
      <p class="text-center text-gray-600 text-sm mt-4">
        Don't have an account?
        <router-link to="/register" class="text-blue-500 hover:text-blue-800">Register here</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import authService from '../services/authService'; // Import the new authService

const email = ref('');
const password = ref('');
const errorMessage = ref('');
const isLoggingIn = ref(false);
const router = useRouter();

const handleLogin = async () => {
  errorMessage.value = ''; // Clear previous errors
  isLoggingIn.value = true; // Set loading state

  try {
    await authService.login(email.value, password.value);
    router.push('/dashboard'); // Redirect to dashboard on successful login
  } catch (error) {
    errorMessage.value = error.message || 'An unexpected error occurred during login.';
  } finally {
    isLoggingIn.value = false; // Reset loading state
  }
};
</script>

<style scoped>
/* Add any component-specific styles here if needed */
</style>
