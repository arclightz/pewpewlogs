<template>
    <div class="bg-blue-900 text-white">
      <div class="container mx-auto px-4">
        <div class="flex justify-between items-center py-4">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-yellow-400 mr-8">PewPewLogs</h1>
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
            <button @click="logout" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-full transition duration-300">
              Logout
            </button>
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
  import { ref } from 'vue';
  import { useRouter } from 'vue-router';
  import { logout } from '../services/authService';
  
  const router = useRouter();
  
  const menuItems = ref([
    { name: 'Dashboard', path: '/dashboard' },
    { name: 'Sessions', path: '/sessions' },
    { name: 'Weapons', path: '/weapons' },
    { name: 'Statistics', path: '/statistics' },
  ]);
  
  const handleLogout = async () => {
    await logout();
    router.push('/');
  };
  </script>