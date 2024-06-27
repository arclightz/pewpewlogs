<template>
  <div class="bg-blue-900 text-white">
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center py-4">
        <div class="flex items-center">
          <nav class="hidden md:flex space-x-4">
            <router-link
              v-for="item in menuItems"
              :key="item.path"
              :to="item.path"
              class="text-white hover:text-yellow-400 transition duration-300"
            >
              {{ item.name }}
            </router-link>
          </nav>
        </div>
        <div class="flex items-center">
          <button
            v-if="user"
            @click="handleLogout"
            class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-full transition duration-300"
          >
            Logout
          </button>
          <div v-else>
            <button
              @click="handleLogin"
              class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full mr-2 transition duration-300"
            >
              Login
            </button>
            <button
              @click="handleRegister"
              class="bg-yellow-400 hover:bg-yellow-500 text-blue-900 font-bold py-2 px-4 rounded-full transition duration-300"
            >
              Sign Up
            </button>
          </div>
        </div>
      </div>
    </div>
    <!-- Mobile menu (hidden on larger screens) -->
    <div class="md:hidden">
      <div class="px-2 pt-2 pb-3 space-y-1">
        <router-link
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          class="block px-3 py-2 rounded-md text-base font-medium text-white hover:text-yellow-400 hover:bg-blue-800 transition duration-300"
        >
          {{ item.name }}
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue';
import { useRouter } from 'vue-router';
import state from '../services/state';

const user = computed(() => state.user);

const router = useRouter();

const menuItems = ref([
  { name: 'Dashboard', path: '/dashboard' },
  { name: 'Sessions', path: '/sessions' },
  { name: 'Weapons', path: '/weapons' },
  { name: 'Statistics', path: '/stats' },
]);

const handleLogin = () => {
  state.kinde.login();
};

const handleRegister = () => {
  state.kinde.register();
};

const handleLogout = async () => {
  await state.kinde.logout();
  state.user = null;
  router.push('/');
};
</script>

<style scoped>
/* Add any styles you need for the TopNavBar component */
</style>
