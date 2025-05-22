<template>
  <div class="flex flex-col items-center justify-center min-h-[calc(100vh-80px)] px-4">
    <WeaponForm @weapon-saved="handleWeaponSaved" />
    <div v-if="successMessage" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mt-6 w-full max-w-xl" role="alert">
      <span class="block sm:inline">{{ successMessage }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import WeaponForm from '../components/WeaponForm.vue'; // Import the WeaponForm component

const router = useRouter();
const successMessage = ref('');

const handleWeaponSaved = (weapon) => {
  successMessage.value = `Weapon added successfully! Redirecting to weapons list...`;
  setTimeout(() => {
    router.push('/weapons'); // Redirect to weapons list after a short delay
  }, 2000); // 2-second delay
};
</script>

<style scoped>
/* Scoped styles for this component */
</style>
