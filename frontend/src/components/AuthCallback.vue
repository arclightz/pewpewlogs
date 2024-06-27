<template>
  <div>
    <p>Loading...</p>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import state from '../services/state';

const router = useRouter();

onMounted(async () => {
  if (state.kinde) {
    // Finalize the authentication process
    const user = await state.kinde.getUser(); // Use await to handle async operation
    if (user) {
      state.user = user;
      router.push('/dashboard'); // Redirect to the dashboard or any other route
    } else {
      router.push('/'); // Redirect to the landing page if no user is found
    }
  }
});
</script>

<style scoped>
/* Add any styles you need for the callback component */
</style>
