<template>
  <div class="flex flex-col items-center justify-center min-h-[calc(100vh-80px)] px-4">
    <SessionForm @session-saved="handleSessionSaved" />
    <div v-if="successMessage" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mt-6 w-full max-w-xl" role="alert">
      <span class="block sm:inline">{{ successMessage }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import SessionForm from '../components/SessionForm.vue'; // Import the SessionForm component

const router = useRouter();
const successMessage = ref('');

const handleSessionSaved = (session) => {
  successMessage.value = `Session logged successfully! Redirecting to sessions list...`;
  setTimeout(() => {
    router.push('/sessions'); // Redirect to sessions list after a short delay
  }, 2000); // 2-second delay
};
</script>

<style scoped>
/* Scoped styles for this component */
</style>
