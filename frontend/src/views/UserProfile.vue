<template>
  <div class="px-4 py-8 w-full min-h-screen">
    <h1 class="text-3xl font-bold mb-6 text-center">Käyttäjäprofiili</h1>

    <div v-if="state.user" class="space-y-8">
      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4 text-white">Tilitiedot</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="flex items-center">
            <strong class="w-24 text-gray-400">Nimi:</strong>
            <span class="text-xl text-white">{{ state.user.name }}</span>
          </div>
          <div class="flex items-center">
            <strong class="w-24 text-gray-400">Sähköposti:</strong>
            <span class="text-xl text-white">{{ state.user.email }}</span>
          </div>
          </div>
      </div>

      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4 text-white">Kirjauksien yleiskatsaus</h2>
        <div v-if="sessionsLoading" class="text-gray-300">Ladataan istuntotietoja...</div>
        <div v-else-if="sessionsError" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
          <span class="block sm:inline">Virhe istuntojen latauksessa: {{ sessionsError }}</span>
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
          <div>
            <p class="text-gray-300">Päiväkirjamerkintöjä yhteensä: <span class="font-bold text-white">{{ sessions.length }}</span></p>
            <p class="text-gray-300" v-if="timeSinceLastSession">Aika viimeisestä istunnosta: <span class="font-bold text-white">{{ timeSinceLastSession }}</span></p>
            <p class="text-gray-300" v-else>Ei istuntoja kirjattu vielä.</p>
          </div>
          <div class="md:text-right">
            <router-link
              to="/sessions"
              class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
            >
              Siirry päiväkirjaan
            </router-link>
          </div>
        </div>
      </div>

      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4 text-white">Aseiden inventaario</h2>
        <div v-if="weaponsLoading" class="text-gray-300">Ladataan asetietoja...</div>
        <div v-else-if="weaponsError" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
          <span class="block sm:inline">Virhe aseiden latauksessa: {{ weaponsError }}</span>
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
          <p class="text-gray-300">Aseita yhteensä: <span class="font-bold text-white">{{ weapons.length }}</span></p>
          <div class="md:text-right">
            <router-link
              to="/weapons"
              class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg shadow-lg transition duration-300 ease-in-out transform hover:scale-105"
            >
              Siirry asevarastoon
            </router-link>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="text-center text-lg text-gray-300 mt-10">
      <p>Käyttäjätietoja ei saatavilla. Kirjaudu sisään nähdäksesi profiilisi.</p>
      <router-link to="/login" class="text-blue-400 hover:underline mt-4 block">Siirry kirjautumissivulle</router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import state from '../services/state';
import { useSessions } from '../composables/useSessions';
import { useWeapons } from '../composables/useWeapons';

const { sessions, loading: sessionsLoading, error: sessionsError, fetchSessions } = useSessions();
const { weapons, loading: weaponsLoading, error: weaponsError, fetchWeapons } = useWeapons();

const timeSinceLastSession = computed(() => {
  if (sessions.value.length === 0) {
    return null;
  }
  const lastSessionDate = new Date(sessions.value[0].date);
  const now = new Date();
  const diffTime = Math.abs(now - lastSessionDate);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 0) return 'Tänään'; // Today
  if (diffDays === 1) return '1 päivä sitten'; // 1 day ago
  return `${diffDays} päivää sitten`; // X days ago
});

onMounted(() => {
  fetchSessions();
  fetchWeapons();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
