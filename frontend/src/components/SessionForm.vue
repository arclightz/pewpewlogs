<template>
  <div class="px-4 py-8 lg:px-8 lg:py-16 w-full min-h-full">
    <form @submit.prevent="handleSubmit" class="bg-gray-800 p-8 rounded-lg shadow-xl w-full max-w-xl mx-auto text-gray-100">
      <h2 class="text-2xl font-bold mb-6 text-center">{{ isEdit ? 'Muokkaa istuntoa' : 'Kirjaa uusi istunto' }}</h2>

      <div class="space-y-4">
        <div class="space-y-1">
          <label for="date" class="inline-block text-sm font-medium">Päivämäärä:</label>
          <input
            type="date"
            id="date"
            v-model="sessionForm.date"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            required
          />
        </div> 

        <div class="space-y-1">
          <label for="range" class="inline-block text-sm font-medium">Ampumarata:</label>
          <select
            id="range"
            v-model="sessionForm.rangeId"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            required
          >
            <option value="" disabled selected>Valitse ampumarata</option>
            <option v-for="range in ranges" :key="range._id" :value="range._id">
              {{ range.name }}
              </option>
          </select>
          <p v-if="rangesLoading" class="text-gray-300 text-sm mt-1">Ladataan ampumaratoja...</p>
          <p v-if="rangesError" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm mt-1" role="alert">
            Virhe ratojen latauksessa: {{ rangesError }}
          </p>
          <p v-if="ranges.length === 0 && !rangesLoading" class="text-gray-300 text-sm mt-1">
            Ei ampumaratoja. <router-link to="/ranges/new" class="underline text-blue-400 hover:text-blue-300">Lisää ampumarata</router-link> ensin.
          </p>
        </div>

        <div class="space-y-1">
          <label for="weapon" class="inline-block text-sm font-medium">Käytetty ase:</label>
          <select
            id="weapon"
            v-model="sessionForm.weaponId"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            required
          >
            <option value="" disabled selected>Valitse ase</option>
            <option v-for="weapon in weapons" :key="weapon._id" :value="weapon._id">
              {{ weapon.name }} ({{ weapon.type }})
            </option>
          </select>
          <p v-if="weaponsLoading" class="text-gray-300 text-sm mt-1">Ladataan aseita...</p>
          <p v-if="weaponsError" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm mt-1" role="alert">
            Virhe aseiden latauksessa: {{ weaponsError }}
          </p>
          <p v-if="weapons.length === 0 && !weaponsLoading" class="text-gray-300 text-sm mt-1">
            Ei aseita. <router-link to="/weapons/new" class="underline text-blue-400 hover:text-blue-300">Lisää ase</router-link> ensin.
          </p>
        </div>

        <div class="space-y-1">
          <label for="ammunitionType" class="inline-block text-sm font-medium">Ammustyyppi:</label>
          <input
            type="text"
            id="ammunitionType"
            v-model="sessionForm.ammunitionType"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            placeholder="esim. 9mm FMJ, .22LR"
          />
        </div>

        <div class="space-y-1">
          <label for="ammunitionCount" class="inline-block text-sm font-medium">Ammusten määrä:</label>
          <input
            type="number"
            id="ammunitionCount"
            v-model.number="sessionForm.ammunitionCount"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            min="0"
          />
        </div>

        <div class="space-y-1">
          <label for="shotsFired" class="inline-block text-sm font-medium">Laukauksia yhteensä:</label>
          <input
            type="number"
            id="shotsFired"
            v-model.number="sessionForm.numberOfShotsFired"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            min="0"
          />
        </div>

        <div class="space-y-1">
          <label for="distance" class="inline-block text-sm font-medium">Etäisyys maaliin (metriä):</label>
          <input
            type="number"
            id="distance"
            v-model.number="sessionForm.distanceToTarget"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            min="0"
          />
        </div>

        <div class="flex space-x-4">
          <div class="flex-1 space-y-1">
            <label for="hits" class="inline-block text-sm font-medium">Osumat:</label>
            <input
              type="number"
              id="hits"
              v-model.number="sessionForm.hits"
              class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
              min="0"
            />
          </div>
          <div class="flex-1 space-y-1">
            <label for="misses" class="inline-block text-sm font-medium">Hutit:</label>
            <input
              type="number"
              id="misses"
              v-model.number="sessionForm.misses"
              class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
              min="0"
            />
          </div>
        </div>

        <div class="space-y-1">
          <label for="notes" class="inline-block text-sm font-medium">Istunnon muistiinpanot:</label>
          <textarea
            id="notes"
            v-model="sessionForm.notes"
            rows="3"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            placeholder="Lisää havaintoja tai yksityiskohtia tästä istunnosta..."
          ></textarea>
        </div>

        <div v-if="errorMessage" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
          {{ errorMessage }}
        </div>

        <div>
          <button
            type="submit"
            class="inline-flex w-full items-center justify-center gap-2 rounded-lg border border-blue-700 bg-blue-700 px-6 py-3 leading-6 font-semibold text-white hover:border-blue-600 hover:bg-blue-600 focus:ring-3 focus:ring-blue-400/50 active:border-blue-700 active:bg-blue-700"
            :disabled="loading || weaponsLoading || rangesLoading"
          >
            <svg
              class="hi-mini hi-arrow-uturn-right inline-block size-5 opacity-50"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fill-rule="evenodd"
                d="M12.207 2.232a.75.75 0 00.025 1.06l4.146 3.958H6.375a5.375 5.375 0 000 10.75H9.25a.75.75 0 000-1.5H6.375a3.875 3.875 0 010-7.75h10.003l-4.146 3.957a.75.75 0 001.036 1.085l5.5-5.25a.75.75 0 000-1.085l-5.5-5.25a.75.75 0 00-1.06.025z"
                clip-rule="evenodd"
              />
            </svg>
            <span>{{ loading ? 'Tallennetaan...' : (isEdit ? 'Päivitä istunto' : 'Kirjaa istunto') }}</span>
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, defineProps, defineEmits, watch } from 'vue';
import { useSessions } from '../composables/useSessions';
import { useWeapons } from '../composables/useWeapons';
import { useApi } from '../composables/useApi';
import api from '../services/api';
// Removed direct axios import here as it's not used for Nominatim in this component
// import axios from 'axios';

const props = defineProps({
  initialSession: {
    type: Object,
    default: null,
  },
  isEdit: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['session-saved']);

const { createSession, loading, error } = useSessions();
const { weapons, loading: weaponsLoading, error: weaponsError, fetchWeapons } = useWeapons();

const ranges = ref([]);
const rangesLoading = ref(false);
const rangesError = ref(null);
const { execute } = useApi();

const sessionForm = ref({
  date: new Date().toISOString().split('T')[0],
  rangeId: '',
  weaponId: '',
  ammunitionType: '',
  ammunitionCount: 0,
  numberOfShotsFired: 0,
  distanceToTarget: 0,
  hits: 0,
  misses: 0,
  notes: '',
});

const errorMessage = ref('');

const fetchRanges = async () => {
  rangesLoading.value = true;
  try {
    const responseData = await execute(api.get, '/api/ranges');
    ranges.value = responseData; // Corrected line
    console.log("[SessionForm] Fetched ranges:", ranges.value);
  } catch (err) {
    console.error('Virhe ampumaratojen latauksessa:', err);
    rangesError.value = err.message || 'Ampumaratojen lataaminen epäonnistui.';
  } finally {
    rangesLoading.value = false;
  }
};

onMounted(() => {
  fetchWeapons();
  fetchRanges();

  if (props.isEdit && props.initialSession) {
    sessionForm.value = {
      ...props.initialSession,
      date: new Date(props.initialSession.date).toISOString().split('T')[0],
      rangeId: props.initialSession.range?._id || '',
    };
  }
});

watch(() => sessionForm.value.weaponId, (newWeaponId) => {
  if (newWeaponId) {
    const selectedWeapon = weapons.value.find(w => w._id === newWeaponId);
    if (selectedWeapon && selectedWeapon.caliber) {
      sessionForm.value.ammunitionType = selectedWeapon.caliber;
    } else {
      sessionForm.value.ammunitionType = ''; // Clear if no caliber or weapon not found
    }
  } else {
    sessionForm.value.ammunitionType = ''; // Clear if no weapon selected
  }
}, { immediate: true });

watch(() => props.initialSession, (newVal) => {
  if (props.isEdit && newVal) {
    sessionForm.value = {
      ...newVal,
      date: new Date(newVal.date).toISOString().split('T')[0],
      rangeId: newVal.range?._id || '',
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  errorMessage.value = '';
  if (!sessionForm.value.date || !sessionForm.value.rangeId || !sessionForm.value.weaponId) {
    errorMessage.value = 'Täytä päivämäärä, ampumarata ja ase.';
    return;
  }
  try {
    const payload = { ...sessionForm.value };
    payload.date = new Date(payload.date);
    payload.range = payload.rangeId;
    delete payload.rangeId;

    const savedSession = await createSession(payload);
    emit('session-saved', savedSession);
    sessionForm.value = {
      date: new Date().toISOString().split('T')[0],
      rangeId: '',
      weaponId: '',
      ammunitionType: '',
      ammunitionCount: 0,
      numberOfShotsFired: 0,
      distanceToTarget: 0,
      hits: 0,
      misses: 0,
      notes: '',
    };
  } catch (err) {
    errorMessage.value = err.message || 'Istunnon tallentaminen epäonnistui.';
  }
};
</script>

<style scoped>
/* Scoped styles for this component */
</style>
