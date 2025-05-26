<template>
  <div class="px-4 py-8 relative min-h-screen">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Ampumaratasi</h1>
      <div class="flex items-center space-x-4">
        <button class="text-white hover:text-blue-200 focus:outline-none">
          <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01.293.707V19a1 1 0 01-1 1H4a1 1 0 01-1-1V4zm0 0L9 12m-6 0h6m-6 0h.01"></path>
          </svg>
        </button>
        <button class="text-white hover:text-blue-200 focus:outline-none">
          <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center text-lg text-gray-300">Ladataan ampumaratoja...</div>
    <div v-else-if="error" class="bg-red-800 text-white px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">Virhe ampumaratojen latauksessa: {{ error }}</span>
    </div>
    <div v-else-if="ranges.length === 0" class="text-center text-lg text-gray-300 mt-10">
      <p>Ei ampumaratoja tallennettu vielä.</p>
      <p class="mt-2">Napsauta '+' -painiketta lisätäksesi ensimmäisen ampumaradan!</p>
    </div>
    <div v-else>
      <div class="hidden md:block overflow-x-auto bg-gray-800 rounded-lg shadow-lg">
        <table class="min-w-full divide-y divide-gray-700">
          <thead class="bg-gray-700">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider"></th> <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Nimi</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Osoite</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-200 uppercase tracking-wider">Verkkosivusto</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-700">
            <template v-for="range in ranges" :key="range._id">
              <tr class="hover:bg-gray-700 transition-colors duration-200">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  <button @click="toggleDetails(range._id)" class="text-blue-400 hover:text-blue-300 focus:outline-none">
                    <svg class="w-5 h-5 transform transition-transform duration-200" :class="{'rotate-90': expandedRanges.has(range._id)}" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5" xmlns="http://www.w3.org/2000/svg">
                      <path stroke-linecap="round" stroke-linejoin="round" :d="SVG_ICONS.expand" />
                    </svg>
                  </button>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">{{ range.name }}</td>
                <td class="px-6 py-4 text-sm text-gray-300">{{ range.address }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  <a v-if="range.website" :href="range.website" target="_blank" class="text-blue-400 hover:underline">Linkki</a>
                  <span v-else>N/A</span>
                </td>
              </tr>
              <tr v-if="expandedRanges.has(range._id)" class="bg-gray-700">
                <td :colspan="tableColumnCount" class="p-4">
                  <div class="bg-gray-900 p-4 rounded-lg shadow-inner text-sm text-gray-300 grid grid-cols-1 md:grid-cols-2 gap-4 items-start">
                    <div class="space-y-2">
                      <p><span class="font-medium text-gray-400">Puhelin:</span> {{ range.phoneNumber || 'N/A' }}</p>
                      <p><span class="font-medium text-gray-400">Koordinaatit:</span> {{ range.location.coordinates[1].toFixed(6) }}, {{ range.location.coordinates[0].toFixed(6) }}</p>
                      <p v-if="range.notes"><span class="font-medium text-gray-400">Muistiinpanot:</span> {{ range.notes || '-' }}</p>
                    </div>
                    
                    <div class="mt-4 md:mt-0 flex justify-center items-center w-full">
                      <div class="w-full h-48 rounded-lg overflow-hidden shadow-md border-2 border-gray-600">
                        <LMap
                          :zoom="12"
                          :center="{ lat: range.location.coordinates[1], lng: range.location.coordinates[0] }"
                          :dragging="false"       
                          :touchZoom="false"      
                          :doubleClickZoom="false" 
                          :boxZoom="false"        
                          :keyboard="false"       
                          :scrollWheelZoom="true" 
                          :zoomControl="false"    
                          :attributionControl="false" 
                          style="height: 100%; width: 100%;"
                        >
                          <LTileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                                     attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors" />
                          <LMarker :lat-lng="{ lat: range.location.coordinates[1], lng: range.location.coordinates[0] }" />
                        </LMap>
                      </div>
                    </div>
                  </div>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>

      <div class="md:hidden space-y-4">
        <div v-for="range in ranges" :key="range._id" class="bg-gray-800 p-4 rounded-lg shadow-md">
          <h3 class="text-lg font-semibold mb-2">{{ range.name }}</h3>
          <div class="text-sm text-gray-300 space-y-1">
            <p><span class="font-medium text-gray-400">Osoite:</span> {{ range.address }}</p>
            <p v-if="range.website"><span class="font-medium text-gray-400">Verkkosivusto:</span> <a :href="range.website" target="_blank" class="text-blue-400 hover:underline">Linkki</a></p>
          </div>
          <div class="mt-3 border-t border-gray-700 pt-3">
            <button @click="toggleDetails(range._id)" class="w-full text-left font-semibold text-blue-400 hover:text-blue-300 focus:outline-none">
              {{ expandedRanges.has(range._id) ? 'Piilota tiedot' : 'Näytä lisätiedot' }}
              <svg class="inline-block w-4 h-4 ml-2 transform transition-transform duration-200" :class="{'rotate-90': expandedRanges.has(range._id)}" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" :d="SVG_ICONS.expand" />
              </svg>
            </button>
            <div v-if="expandedRanges.has(range._id)" class="space-y-1 mt-2">
              <p><span class="font-medium text-gray-400">Puhelin:</span> {{ range.phoneNumber || 'N/A' }}</p>
              <p><span class="font-medium text-gray-400">Koordinaatit:</span> {{ range.location.coordinates[1].toFixed(6) }}, {{ range.location.coordinates[0].toFixed(6) }}</p>
              <p v-if="range.notes"><span class="font-medium text-gray-400">Muistiinpanot:</span> {{ range.notes || '-' }}</p>
              <div class="mt-4">
                <h4 class="font-medium text-gray-400 mb-2">Karttasijainti:</h4>
                <LMap
                  :zoom="12"
                  :center="{ lat: range.location.coordinates[1], lng: range.location.coordinates[0] }"
                  style="height: 150px; width: 100%; border-radius: 0.5rem;"
                  class="overflow-hidden"
                >
                  <LTileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                             attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> contributors" />
                  <LMarker :lat-lng="{ lat: range.location.coordinates[1], lng: range.location.coordinates[0] }" />
                </LMap>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <router-link
      to="/ranges/new"
      class="fixed right-8 bg-green-500 hover:bg-green-600 text-white p-4 rounded-full shadow-lg transition duration-300 ease-in-out transform hover:scale-110 focus:outline-none bottom-24 md:bottom-8"
    >
      <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
      </svg>
    </router-link>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRanges } from '../composables/useRanges';
import { SVG_ICONS } from '../constants/menuItems';
import { LMap, LTileLayer, LMarker } from '@vue-leaflet/vue-leaflet';
import 'leaflet/dist/leaflet.css';

// Workaround for Leaflet's default icon issue with Webpack/Vite
import L from 'leaflet';
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';
L.Marker.prototype.options.icon = L.icon({
  iconRetinaUrl,
  iconUrl,
  shadowUrl,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  tooltipAnchor: [16, -28],
  shadowSize: [41, 41]
});

const { ranges, loading, error, fetchRanges } = useRanges();

const expandedRanges = ref(new Set());

const expandIconPath = SVG_ICONS.expand;

const tableColumnCount = computed(() => {
  return 4; // Expand icon + Name + Address + Website
});

const toggleDetails = (rangeId) => {
  if (expandedRanges.value.has(rangeId)) {
    expandedRanges.value.delete(rangeId);
  } else {
    expandedRanges.value.add(rangeId);
  }
  expandedRanges.value = new Set(expandedRanges.value);
};

onMounted(() => {
  fetchRanges();
});
</script>

<style scoped>
/* Scoped styles for this component */
</style>
