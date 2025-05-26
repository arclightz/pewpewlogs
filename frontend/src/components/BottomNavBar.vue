<template>
  <nav class="fixed bottom-0 left-0 w-full bg-gray-800 text-white shadow-lg p-3 md:hidden z-30">
    <div class="flex justify-around items-center h-full">
      <router-link
        v-for="item in mobileBottomNavItems"
        :key="item.name"
        :to="item.path"
        class="flex flex-col items-center justify-center text-xs text-white hover:text-blue-400 p-1 rounded-lg"
        active-class="text-blue-400"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" :d="item.icon"></path>
        </svg>
        <span>{{ item.name }}</span>
      </router-link>

      <button @click="toggleMoreMenu" class="flex flex-col items-center justify-center text-xs text-white hover:text-blue-400 p-1 rounded-lg">
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M5 12h.01M12 12h.01M19 12h.01"></path>
        </svg>
        <span>Lisää</span>
      </button>
    </div>

    <MobileMoreMenu :is-open="isMoreMenuOpen" @close="closeMoreMenu" />
  </nav>
</template>

<script setup>
import { ref } from 'vue';
import MobileMoreMenu from './MobileMoreMenu.vue';
import { mobileBottomNavItems } from '../constants/menuItems'; // Correct import

const isMoreMenuOpen = ref(false);

const toggleMoreMenu = () => {
  isMoreMenuOpen.value = !isMoreMenuOpen.value;
};

const closeMoreMenu = () => {
  isMoreMenuOpen.value = false;
};
</script>

<style scoped>
/* Ensure active link has a distinct color */
.router-link-active {
  color: #60a5fa; /* A lighter blue for active link */
}
</style>
