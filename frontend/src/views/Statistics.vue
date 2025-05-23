<template>
  <div class="px-4 py-8 w-full min-h-screen">
    <h1 class="text-3xl font-bold mb-6 text-left">Ampumatilastosi</h1>

    <div v-if="loading" class="text-center text-lg text-gray-300">Ladataan tilastoja...</div>
    <div v-else-if="error" class="bg-red-800 text-white px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">Virhe tilastojen latauksessa: {{ error }}</span>
    </div>
    <div v-else-if="!stats || (stats.overall.totalSessions === 0 && stats.shotsPerWeapon.length === 0)" class="text-center text-lg text-gray-300 mt-10">
      <p>Ei tilastoja saatavilla. Kirjaa istuntoja nähdäksesi edistymisesi!</p>
      <router-link to="/sessions/new" class="text-blue-400 hover:underline mt-4 block">Kirjaa ensimmäinen istuntosi!</router-link>
    </div>
    <div v-else class="space-y-8">
      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4 text-white">Yleinen suorituskyky</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <p class="text-gray-300">Kirjattuja harjoitteita: <span class="font-bold text-white">{{ stats.overall.totalSessions }}</span></p>
          <p class="text-gray-300">Laukauksia yhteensä: <span class="font-bold text-white">{{ stats.overall.totalShotsFired }}</span></p>
          <p class="text-gray-300">Osumia yhteensä: <span class="font-bold text-white">{{ stats.overall.totalHits }}</span></p>
          <p class="text-gray-300">Huteja yhteensä: <span class="font-bold text-white">{{ stats.overall.totalMisses }}</span></p>
          <p class="text-gray-300 col-span-full">Tarkkuus: <span class="font-bold text-white">{{ stats.overall.accuracyPercentage.toFixed(2) }}%</span></p>
        </div>
      </div>

      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4 text-white">Laukauksia per ase</h2>
        <div v-if="stats.shotsPerWeapon.length > 0" class="overflow-x-auto">
          <table class="min-w-full bg-gray-700 rounded-lg overflow-hidden">
            <thead>
              <tr>
                <th class="py-2 px-4 text-left text-gray-200">Aseen nimi</th>
                <th class="py-2 px-4 text-left text-gray-200">Tyyppi</th>
                <th class="py-2 px-4 text-left text-gray-200">Laukauksia yhteensä</th>
                <th class="py-2 px-4 text-left text-gray-200">Käytetty harjoitteissa</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="weaponStat in stats.shotsPerWeapon" :key="weaponStat.weaponId" class="border-t border-gray-600">
                <td class="py-2 px-4 text-gray-300">{{ weaponStat.weaponName || 'Tuntematon ase' }}</td>
                <td class="py-2 px-4 text-gray-300">{{ weaponStat.weaponType || 'N/A' }}</td>
                <td class="py-2 px-4 text-gray-300">{{ weaponStat.totalShots }}</td>
                <td class="py-2 px-4 text-gray-300">{{ weaponStat.totalSessions }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <p v-else class="text-gray-300">Aseiden käyttötietoja ei saatavilla.</p>
      </div>

      <div class="bg-gray-800 p-6 rounded-lg shadow-md">
        <h2 class="text-2xl font-semibold mb-4 text-white">Edistyminen ajan mittaan</h2>
        <p class="text-gray-300">(Graafit ja kaaviot tulossa pian!)</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue';
import { useStats } from '../composables/useStats';

const { stats, loading, error, fetchStats } = useStats();

onMounted(() => {
  fetchStats();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
