<template>
  <div class="flex items-center justify-center min-h-screen bg-blue-900">
    <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md text-gray-800">
      <h2 class="text-2xl font-bold mb-6 text-center">Register for Pewpewlogs</h2>

      <form @submit.prevent="handleRegister">
        <div class="mb-4">
          <label for="name" class="block text-black text-sm font-bold mb-2">Name:</label>
          <input
            type="text"
            id="name"
            v-model="name"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-white bg-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            required
          />
        </div>
        <div class="mb-4">
          <label for="email" class="block text-black text-sm font-bold mb-2">Email:</label>
          <input
            type="email"
            id="email"
            v-model="email"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-white bg-gray-700 leading-tight focus:outline-none focus:shadow-outline"
            required
          />
        </div>
        <div class="mb-6">
          <label for="password" class="block text-black text-sm font-bold mb-2">Password:</label>
          <input
            type="password"
            id="password"
            v-model="password"
            class="shadow appearance-none border rounded w-full py-2 px-3 text-white bg-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline"
            required
          />
        </div>
        <div v-if="errorMessage" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
          <span class="block sm:inline">{{ errorMessage }}</span>
        </div>
        <div v-if="successMessage" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
          <span class="block sm:inline">{{ successMessage }}</span>
        </div>
        <div class="flex items-center justify-between">
          <button
            type="submit"
            class="bg-green-500 hover:bg-green-700 text-black font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full"
            :disabled="isRegistering"
          >
            {{ isRegistering ? 'Registering...' : 'Register' }}
          </button>
        </div>
      </form>
      <p class="text-center text-white text-sm mt-4">
        Already have an account?
        <router-link to="/login" class="text-blue-200 hover:text-blue-400">Login here</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import authService from '../services/authService'; // Import the new authService

const name = ref('');
const email = ref('');
const password = ref('');
const errorMessage = ref('');
const successMessage = ref('');
const isRegistering = ref(false);
const router = useRouter();

const handleRegister = async () => {
  errorMessage.value = ''; // Clear previous errors
  successMessage.value = ''; // Clear previous success messages
  isRegistering.value = true; // Set loading state

  try {
    const response = await authService.register(name.value, email.value, password.value);
    successMessage.value = response.message; // Display success message
    // Optionally, redirect to login page after successful registration
    // router.push('/login');
  } catch (error) {
    // Log the full error object to the console for detailed debugging
    console.error('Registration failed:', error);
    errorMessage.value = error.message || 'An unexpected error occurred during registration.';
  } finally {
    isRegistering.value = false; // Reset loading state
  }
};
</script>

<style scoped>
/* Add any component-specific styles here if needed */
</style>
