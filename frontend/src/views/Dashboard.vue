<template>
  <div class="px-4 py-8 w-full min-h-screen">
    <h1 class="text-4xl font-bold mb-6 text-center">Joko ammutaan lisää, {{ state.user?.name || state.user?.email || 'User' }}!</h1>
    <p class="text-lg mb-8 text-center"> Voit täällä kätevästi tarkastella ampumasessioitasi ja tilastojasi sekä hallinnoida aseitasi.
    </p>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 w-full max-w-4xl mx-auto"> <router-link
        to="/sessions"
        class="bg-blue-700 hover:bg-blue-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z" />
        </svg>
        <span class="text-xl font-semibold">Päiväkirja</span>
      </router-link>

      <router-link
        to="/sessions/new"
        class="bg-green-700 hover:bg-green-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <span class="text-xl font-semibold">Kirjaa uusi harjoite</span>
      </router-link>

      <router-link
        to="/weapons"
        class="bg-purple-700 hover:bg-purple-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 122.88 89.54" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="5" d="M9.51,5.81l0.03-0.1c1.25-2.88,2.16-4.31,3.91-5.14c2.5-1.18,4.98-0.49,6.62,1.68 c0.78,1.03,1.38,2.24,1.85,3.56h82.67V5.26c0-2.82,2.31-5.13,5.13-5.13h5.39c0.97,0,1.77,0.8,1.77,1.77v3.9h1.29 c2.59,0,4.71,2.12,4.71,4.71v10.93H62.86v-6.3c0-1.1-0.89-1.99-1.99-1.99c-1.1,0-1.99,0.89-1.99,1.99v6.3h-4.78v-6.3 c0-1.1-0.89-1.99-1.99-1.99c-1.1,0-1.99,0.89-1.99,1.99v6.3h-4.78v-6.3c0-1.1-0.89-1.99-1.99-1.99c-1.1,0-1.99,0.89-1.99,1.99v6.3 h-4.78v-6.3c0-1.1-0.89-1.99-1.99-1.99c-1.1,0-1.99,0.89-1.99,1.99v6.3h-4.78v-6.3c0-1.1-0.89-1.99-1.99-1.99 c-1.1,0-1.99,0.89-1.99,1.99v6.3H19v-6.3c0-1.1-0.89-1.99-1.99-1.99c-1.1,0-1.99,0.89-1.99,1.99v6.3h-4.78v-6.3 c0-1.1-0.89-1.99-1.99-1.99c-1.1,0-1.99,0.89-1.99,1.99v6.3H0.27c-0.07,0-0.13,0-0.2,0.01C0.02,20.79,0,20.07,0,19.31v-8.8 c0-2.59,2.12-4.7,4.7-4.7H9.51L9.51,5.81z M122.88,25.44v2.67c0,2.59-2.12,4.71-4.71,4.71l-35.52,3.73V25.44H122.88L122.88,25.44z M78.68,36.96l-4.81,0.51c0.82,8.68-0.39,14.49-5.55,18.1c-4.85,3.39-13.12,4.45-26.6,3.76c-0.12-0.01-0.25-0.02-0.36-0.05 l-2.4,8.8H2.54c0.32-0.76,0.68-1.56,1.08-2.43c1.33-2.94,2.88-5.72,4.66-8.33c4.68-7.91,7.87-14.82,8.2-19.46 c0.77-10.83-12.62-0.46-15.8-12.42h78v11.33C78.67,36.83,78.67,36.9,78.68,36.96L78.68,36.96z M38.12,71.15l-1.43,5.24 c3.01,4.39,3.73,7.91,1.71,10.38c-2.93,3.59-8.13,2.66-12.22,2.66H7.01c-5.17-0.45-7.19-3.9-6.91-9.54c0-3.65,0.38-6.11,1.26-8.75 H38.12L38.12,71.15z M69.92,37.88L58.2,39.11c-1.28,0.04-2.5,0.17-3.66,0.4c0.05,0.16,0.08,0.34,0.08,0.51 c0.05,2.03,0.77,3.69,1.86,4.88c1.17,1.28,2.8,2.03,4.52,2.14c1.1,0.07,1.93,1.01,1.86,2.11c-0.07,1.1-1.01,1.93-2.11,1.86 c-2.74-0.17-5.32-1.38-7.2-3.42c-1.58-1.72-2.65-4.03-2.87-6.8c-3.79,1.91-6.5,5.61-7.57,12.03l-0.69,2.54 c12.26,0.6,19.63-0.27,23.63-3.06C69.76,49.72,70.58,45.04,69.92,37.88L69.92,37.88z"</path>
        </svg>
        <span class="text-xl font-semibold">Hallitse aseitasi</span>
      </router-link>

      <router-link
        to="/statistics"
        class="bg-yellow-700 hover:bg-yellow-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7.5 14.25v2.25m3-4.5v4.5m3-6.75v6.75m3-9v9M6 20.25h12A2.25 2.25 0 0 0 20.25 18V6A2.25 2.25 0 0 0 18 3.75H6A2.25 2.25 0 0 0 3.75 6v12A2.25 2.25 0 0 0 6 20.25Z"></path>
        </svg>
        <span class="text-xl font-semibold">Tilastot</span>
      </router-link>

      <router-link
        to="/profile"
        class="bg-indigo-700 hover:bg-indigo-600 p-6 rounded-lg shadow-md flex flex-col items-center justify-center transition duration-300 ease-in-out transform hover:scale-105"
      >
        <svg class="w-12 h-12 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"></path>
        </svg>
        <span class="text-xl font-semibold">Profiilisi</span>
        </router-link>
      </div>
  </div>
</template>

<script setup>
import state from '../services/state'; // Import global state to display user name
</script>

<style scoped>
/* Scoped styles for this component */
/* Removed text-center class from the root div to prevent overall centering */
/* Individual card content is already centered with flex-col items-center justify-center */
</style>
