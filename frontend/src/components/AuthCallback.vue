<template>
  <div>
    <p>Processing login, please wait...</p>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { handleCallback } from '../services/authService';

const router = useRouter();

onMounted(async () => {
  try {
    await handleCallback();
    // Redirect to a protected route or dashboard
    router.push('/dashboard');
  } catch (error) {
    // Handle error (e.g., show error message, redirect to login page)
    console.error('Authentication failed:', error);
    router.push('/');
  }
});
</script>