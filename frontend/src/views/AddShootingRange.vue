<template>
  <div class="px-4 py-8 lg:px-8 lg:py-16 w-full min-h-full">
    <h1 class="text-3xl font-bold mb-6 text-center">Lisää uusi ampumarata</h1>

    <div class="bg-gray-800 p-6 rounded-lg shadow-md max-w-2xl mx-auto text-gray-100">
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div class="space-y-1">
          <label for="name" class="inline-block text-sm font-medium">Ampumaradan nimi:</label>
          <input type="text" id="name" v-model="rangeForm.name" required
                 class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                 placeholder="esim. Helsingin Ampumarata" />
        </div>

        <div class="space-y-1">
          <label for="addressSearch" class="inline-block text-sm font-medium">Hae osoitetta:</label>
          <input type="text" id="addressSearch" v-model="addressSearchTerm" @input="searchAddress"
                 placeholder="Syötä osoite tai paikan nimi"
                 class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100" />
          <ul v-if="searchResults.length" class="bg-gray-700 border border-gray-600 rounded mt-1 max-h-48 overflow-y-auto">
            <li v-for="result in searchResults" :key="result.osm_id"
                @click="selectAddress(result)"
                class="p-2 cursor-pointer hover:bg-blue-600 text-sm">
              {{ formatNominatimAddress(result.address) }} </li>
          </ul>
        </div>

        <div class="space-y-1">
          <label for="address" class="inline-block text-sm font-medium">Katuosoite:</label>
          <input type="text" id="address" v-model="rangeForm.address" required
                 class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100" />
        </div>

        <div class="space-y-1">
          <label class="block text-sm font-medium mb-2">Sijainti (napsauta karttaa paikantaaksesi):</label>
          <LMap ref="map" :zoom="mapZoom" :center="rangeForm.location" style="height: 400px; width: 100%; border-radius: 0.5rem;" @update:center="handleMapMove" @click="handleMapClick">
            <LTileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                       attribution="&copy; <a href='https://www.openstreetmap.org/copyright'>OpenStreetMap</a> tekijät" />
            <LMarker :lat-lng="rangeForm.location" :draggable="true" @dragend="handleMarkerDrag" />
          </LMap>
          <p class="text-sm text-gray-400 mt-2">Lat: {{ rangeForm.location.lat.toFixed(6) }}, Lng: {{ rangeForm.location.lng.toFixed(6) }}</p>
        </div>

        <div class="space-y-1">
          <label for="website" class="inline-block text-sm font-medium">Verkkosivusto:</label>
          <input type="url" id="website" v-model="rangeForm.website"
                 class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                 placeholder="esim. https://www.example.com" />
        </div>

        <div class="space-y-1">
          <label for="phoneNumber" class="inline-block text-sm font-medium">Puhelinnumero:</label>
          <input type="tel" id="phoneNumber" v-model="rangeForm.phoneNumber"
                 class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                 placeholder="esim. +358 123 456789" />
        </div>

        <div class="space-y-1">
          <label for="notes" class="inline-block text-sm font-medium">Muistiinpanot:</label>
          <textarea id="notes" v-model="rangeForm.notes" rows="3"
                    class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                    placeholder="Lisätietoja ampumaradasta..."></textarea>
        </div>

        <div v-if="errorMessage" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
          {{ errorMessage }}
        </div>

        <div>
          <button type="submit" :disabled="loading"
                  class="inline-flex w-full items-center justify-center gap-2 rounded-lg border border-blue-700 bg-blue-700 px-6 py-3 leading-6 font-semibold text-white hover:border-blue-600 hover:bg-blue-600 focus:ring-3 focus:ring-blue-400/50 active:border-blue-700 active:bg-blue-700">
            <svg class="hi-mini hi-arrow-uturn-right inline-block size-5 opacity-50" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd" d="M12.207 2.232a.75.75 0 00.025 1.06l4.146 3.958H6.375a5.375 5.375 0 000 10.75H9.25a.75.75 0 000-1.5H6.375a3.875 3.875 0 010-7.75h10.003l-4.146 3.957a.75.75 0 001.036 1.085l5.5-5.25a.75.75 0 000-1.085l-5.5-5.25a.75.75 0 00-1.06.025z" clip-rule="evenodd" />
            </svg>
            <span>{{ loading ? 'Tallennetaan...' : 'Tallenna ampumarata' }}</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { LMap, LTileLayer, LMarker } from '@vue-leaflet/vue-leaflet';
import 'leaflet/dist/leaflet.css';
import api from '../services/api';
import { useApi } from '../composables/useApi';
import axios from 'axios';
import { useRouter } from 'vue-router';

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

const router = useRouter();
const { loading, error: apiError, execute } = useApi();
const errorMessage = ref('');

const rangeForm = ref({
  name: '',
  address: '',
  location: { lat: 62.2426, lng: 25.7473 }, // Default to Jyväskylä coordinates
  website: '',
  phoneNumber: '',
  notes: '',
});
const addressSearchTerm = ref('');
const searchResults = ref([]);
const mapZoom = ref(10);

onMounted(() => {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        rangeForm.value.location = {
          lat: position.coords.latitude,
          lng: position.coords.longitude,
        };
        mapZoom.value = 14;
      },
      (error) => {
        console.error('Geolocation error:', error);
        rangeForm.value.location = { lat: 62.2426, lng: 25.7473 };
      }
    );
  } else {
    console.log('Geolocation is not supported by this browser.');
    rangeForm.value.location = { lat: 62.2426, lng: 25.7473 };
  }
});

let searchDebounce = null;
const searchAddress = async () => {
  if (searchDebounce) clearTimeout(searchDebounce);
  searchDebounce = setTimeout(async () => {
    if (addressSearchTerm.value.length < 3) {
      searchResults.value = [];
      return;
    }
    try {
      const response = await axios.get('https://nominatim.openstreetmap.org/search', {
        params: {
          q: addressSearchTerm.value,
          format: 'json',
          addressdetails: 1, // FIX: Request address details for structured data
          limit: 5,
        },
        headers: {
          'User-Agent': 'PewPewLogsApp/1.0 (your-email@example.com)'
        }
      });
      searchResults.value = response.data;
      console.log("[AddShootingRange] Search results:", searchResults.value);
    } catch (err) {
      console.error('[AddShootingRange] Geocoding search failed:', err);
      errorMessage.value = 'Osoitehaku epäonnistui.';
    }
  }, 500);
};

// Helper function to format Nominatim address details
const formatNominatimAddress = (addressDetails) => {
  const parts = [];
  if (addressDetails.road) {
    parts.push(addressDetails.road);
  }
  if (addressDetails.house_number) {
    parts.push(addressDetails.house_number);
  }
  const streetAndNumber = parts.join(' ');

  const cityParts = [];
  if (addressDetails.postcode) {
    cityParts.push(addressDetails.postcode);
  }
  if (addressDetails.city) {
    cityParts.push(addressDetails.city);
  } else if (addressDetails.town) {
    cityParts.push(addressDetails.town);
  } else if (addressDetails.village) {
    cityParts.push(addressDetails.village);
  }
  const postalCodeAndCity = cityParts.join(' ');

  return [streetAndNumber, postalCodeAndCity].filter(Boolean).join(', ');
};

const selectAddress = (result) => {
  rangeForm.value.address = formatNominatimAddress(result.address); // FIX: Use formatted address
  rangeForm.value.location = {
    lat: parseFloat(result.lat),
    lng: parseFloat(result.lon),
  };
  mapZoom.value = 14;
  searchResults.value = [];
  console.log("[AddShootingRange] Selected address, form location updated:", rangeForm.value.location);
};

const handleMapClick = (event) => {
  rangeForm.value.location = {
    lat: event.latlng.lat,
    lng: event.latlng.lng,
  };
  reverseGeocode(event.latlng.lat, event.latlng.lng);
  console.log("[AddShootingRange] Map clicked, form location updated:", rangeForm.value.location);
};

const handleMarkerDrag = (event) => {
  rangeForm.value.location = {
    lat: event.target.getLatLng().lat,
    lng: event.target.getLatLng().lng,
  };
  reverseGeocode(event.target.getLatLng().lat, event.target.getLatLng().lng);
  console.log("[AddShootingRange] Marker dragged, form location updated:", rangeForm.value.location);
};

const handleMapMove = (center) => {
   // console.log('Map moved to:', center);
};

const reverseGeocode = async (lat, lng) => {
  try {
    const response = await axios.get('https://nominatim.openstreetmap.org/reverse', {
      params: {
        lat: lat,
        lon: lng,
        format: 'json',
        addressdetails: 1, // FIX: Request address details for structured data
      },
      headers: {
        'User-Agent': 'PewPewLogsApp/1.0 (your-email@example.com)'
      }
    });
    if (response.data.address) { // FIX: Check for address object
      rangeForm.value.address = formatNominatimAddress(response.data.address); // FIX: Use formatted address
    } else {
      rangeForm.value.address = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
    }
    console.log("[AddShootingRange] Reverse geocoding result:", rangeForm.value.address); // Log formatted result
  } catch (err) {
    console.error('[AddShootingRange] Reverse geocoding failed:', err);
    errorMessage.value = 'Osoitteen hakeminen karttasijainnista epäonnistui.';
  }
};

const handleSubmit = async () => {
  errorMessage.value = '';
  console.log("[AddShootingRange] Submitting form with data:", rangeForm.value);
  if (!rangeForm.value.name || !rangeForm.value.address || rangeForm.value.location.lat === 0 || rangeForm.value.location.lng === 0) {
    errorMessage.value = 'Täytä kaikki pakolliset kentät ja paikanna sijainti kartalta.';
    console.error("[AddShootingRange] Validation failed: Missing required fields.");
    return;
  }

  try {
    const createdRange = await execute(api.post, '/api/ranges', {
      name: rangeForm.value.name,
      address: rangeForm.value.address,
      latitude: rangeForm.value.location.lat,
      longitude: rangeForm.value.location.lng,
      notes: rangeForm.value.notes,
      website: rangeForm.value.website,
      phoneNumber: rangeForm.value.phoneNumber,
    });
    console.log('Ampumarata tallennettu:', createdRange);
    router.push('/ranges');
  } catch (err) {
    console.error('[AddShootingRange] Failed to save shooting range:', err);
    errorMessage.value = err.message || 'Ampumaradan tallentaminen epäonnistui.';
  }
};
</script>

<style scoped>
/* Add custom styles here if needed */
</style>
