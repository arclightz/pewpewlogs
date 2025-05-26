<template>
  <transition name="slide-up">
    <div v-if="isOpen" class="fixed inset-0 bg-gray-900 bg-opacity-95 text-white flex flex-col z-40 p-4">
      <div class="flex justify-end mb-6">
        <button @click="$emit('close')" class="text-white focus:outline-none">
          <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>

      <nav class="flex flex-col space-y-4 text-center text-lg flex-grow justify-center items-center">
        <router-link
          v-for="item in mobileMoreMenuItems"
          :key="item.name"
          :to="item.path"
          class="block w-full py-3 rounded-lg hover:bg-blue-700 transition-colors duration-200"
          @click="$emit('close')"
        >
          <div class="flex items-center justify-center">
            <svg class="w-7 h-7 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="item.icon"></path>
            </svg>
            <span>{{ item.name }}</span>
          </div>
        </router-link>

        <template v-if="state.user">
          <button
            @click="handleLogoutAndCloseMenu"
            class="block w-full py-3 rounded-lg bg-red-700 hover:bg-red-600 transition-colors duration-200"
          >
            <div class="flex items-center justify-center">
              <svg class="w-7 h-7 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
              </svg>
              <span>Kirjaudu ulos</span>
            </div>
          </button>
        </template>
        <template v-else>
          <router-link
            to="/login"
            class="block w-full py-3 rounded-lg bg-blue-700 hover:bg-blue-600 transition-colors duration-200"
            @click="$emit('close')"
          >
            <div class="flex items-center justify-center">
              <svg class="w-7 h-7 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1m-3-1v1m-3-1v1m-3-1v1m-3-1v1a6 6 0 006 6h2a6 6 0 006-6v-1"></path>
              </svg>
              <span>Kirjaudu sisään</span>
            </div>
          </router-link>
        </template>
      </nav>
    </div>
  </transition>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';
import state from '../services/state';
import authService from '../services/authService';
import { useRouter } from 'vue-router';
import { mobileMoreMenuItems } from '../constants/menuItems'; // Correct import

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true,
  },
});

const emit = defineEmits(['close']);
const router = useRouter();

const handleLogoutAndCloseMenu = () => {
  authService.logout();
  emit('close');
};
</script>

<style scoped>
/* Transition for slide-up effect */
.slide-up-enter-active, .slide-up-leave-active {
  transition: all 0.3s ease-out;
}
.slide-up-enter-from, .slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}
</style>
