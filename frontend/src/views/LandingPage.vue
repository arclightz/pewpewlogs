<template>
  <div class="min-h-screen bg-gradient-to-b from-blue-900 to-blue-700 text-white">
    <header class="container mx-auto px-4 py-6">
      <nav class="flex justify-between items-center">
        <h1 class="text-3xl font-bold text-yellow-400">PewPewLogs</h1>
        <div>
          <button v-if="!$state.user" @click="handleLogin" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full mr-2 transition duration-300">Login</button>
          <button v-if="!$state.user" @click="handleRegister" class="bg-yellow-400 hover:bg-yellow-500 text-blue-900 font-bold py-2 px-4 rounded-full transition duration-300">Sign Up</button>
          <button v-if="$state.user" @click="handleLogout" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-full transition duration-300">Logout</button>
        </div>
      </nav>
    </header>
    <main class="container mx-auto px-4 py-12">
      <div class="text-center mb-12">
        <h2 class="text-5xl font-bold mb-4">Track Your Shooting Progress</h2>
        <p class="text-xl mb-8">Log sessions, analyze performance, and improve your accuracy</p>
        <button v-if="!$state.user" @click="handleLogin" class="bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-full text-xl transition duration-300 transform hover:scale-105">Get Started</button>
        <router-link v-else to="/dashboard" class="bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-full text-xl transition duration-300 transform hover:scale-105 inline-block">Go to Dashboard</router-link>
      </div>

      <div class="grid md:grid-cols-3 gap-8 mb-12">
        <div class="bg-white bg-opacity-10 p-6 rounded-lg shadow-lg backdrop-filter backdrop-blur-lg">
          <div class="text-4xl mb-4 text-yellow-400">📊</div>
          <h3 class="text-2xl font-semibold mb-2">Detailed Logging</h3>
          <p class="text-gray-300">Record every aspect of your shooting sessions with ease</p>
        </div>
        <div class="bg-white bg-opacity-10 p-6 rounded-lg shadow-lg backdrop-filter backdrop-blur-lg">
          <div class="text-4xl mb-4 text-yellow-400">📈</div>
          <h3 class="text-2xl font-semibold mb-2">Performance Analytics</h3>
          <p class="text-gray-300">Visualize your progress and identify areas for improvement</p>
        </div>
        <div class="bg-white bg-opacity-10 p-6 rounded-lg shadow-lg backdrop-filter backdrop-blur-lg">
          <div class="text-4xl mb-4 text-yellow-400">🎯</div>
          <h3 class="text-2xl font-semibold mb-2">Goal Setting</h3>
          <p class="text-gray-300">Set and track personal goals to push your limits</p>
        </div>
      </div>

      <div class="text-center bg-blue-800 p-8 rounded-lg shadow-xl">
        <h3 class="text-3xl font-bold mb-4">Ready to Improve Your Shooting?</h3>
        <p class="text-xl mb-6">Join thousands of shooters who are leveling up their game with PewPewLogs</p>
        <button class="bg-yellow-400 hover:bg-yellow-500 text-blue-900 font-bold py-3 px-8 rounded-full text-xl transition duration-300 transform hover:scale-105">Sign Up Now</button>
      </div>
    </main>

    <footer class="container mx-auto px-4 py-6 text-center">
      <p>© 2024 PewPewLogs. All rights reserved.</p>
    </footer>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import state from '../services/state'; 

const router = useRouter();

onMounted(() => {
  if (state.kinde && state.kinde.getUser()) {
    state.user = state.kinde.getUser();
  }
});

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
/* Any additional component-specific styles can go here */
</style>
