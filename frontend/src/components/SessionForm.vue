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
          <div class="flex items-center space-x-2">
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
            <button
              type="button"
              @click="goToAddRange"
              class="flex-shrink-0 bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-3 rounded-lg focus:outline-none focus:shadow-outline"
              title="Lisää uusi ampumarata"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
              </svg>
            </button>
          </div>
          <p v-if="rangesLoading" class="text-gray-300 text-sm mt-1">Ladataan ampumaratoja...</p>
          <p v-if="rangesError" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm mt-1" role="alert">
            Virhe ratojen latauksessa: {{ rangesError }}
          </p>
          <p v-if="ranges.length === 0 && !rangesLoading" class="text-gray-300 text-sm mt-1">
            Ei ampumaratoja. <router-link to="/ranges/new" class="underline text-blue-400 hover:text-blue-300">Lisää ampumarata</router-link> ensin.
          </p>
        </div>

        <div class="space-y-1">
          <label for="type" class="inline-block text-sm font-medium">Suorituksen tyyppi:</label>
          <select
            id="type"
            v-model="sessionForm.type"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            required
          >
            <option value="" disabled selected>Valitse tyyppi</option>
            <option v-for="typeOption in sessionTypes" :key="typeOption" :value="typeOption">{{ typeOption }}</option>
          </select>
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
          <label for="sportType" class="inline-block text-sm font-medium">Laji:</label>
          <select
            id="sportType"
            v-model="sessionForm.sportType"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            required
            :disabled="!sessionForm.weaponId"
          >
            <option value="" disabled selected>Valitse laji</option>
            <option v-for="sportOption in filteredSportTypes" :key="sportOption" :value="sportOption">{{ sportOption }}</option>
          </select>
          <p v-if="!sessionForm.weaponId" class="text-gray-400 text-sm mt-1">Valitse ensin ase nähdäksesi lajit.</p>
        </div>

        <div class="space-y-1">
          <label for="numberOfShotsFired" class="inline-block text-sm font-medium">Laukauksia yhteensä:</label>
          <div class="flex items-center space-x-2">
            <input
              type="number"
              id="numberOfShotsFired"
              v-model.number="sessionForm.numberOfShotsFired"
              class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
              min="0"
            />
            <button type="button" @click="addShots(10)" class="px-3 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg text-sm font-semibold">+10</button>
            <button type="button" @click="addShots(25)" class="px-3 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg text-sm font-semibold">+25</button>
            <button type="button" @click="addShots(50)" class="px-3 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg text-sm font-semibold">+50</button>
            <button type="button" @click="addShots(100)" class="px-3 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg text-sm font-semibold">+100</button>
          </div>
        </div>

        <div class="space-y-1">
          <label for="role" class="inline-block text-sm font-medium">Rooli suorituksen aikana:</label>
          <select
            id="role"
            v-model="sessionForm.role"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
          >
            <option value="" disabled selected>Valitse rooli (valinnainen)</option>
            <option v-for="roleOption in roles" :key="roleOption" :value="roleOption">{{ roleOption }}</option>
          </select>
        </div>

        <div class="space-y-1">
          <label for="weather" class="inline-block text-sm font-medium">Sää:</label>
          <input
            type="text"
            id="weather"
            v-model="sessionForm.weather"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            placeholder="esim. Aurinkoinen, +15°C"
          />
        </div>

        <div class="border-t border-gray-700 pt-4 mt-4">
          <button type="button" @click="toggleOptionalFields" class="w-full text-left font-semibold text-blue-400 hover:text-blue-300 focus:outline-none">
            {{ showOptionalFields ? 'Piilota valinnaiset kentät' : 'Näytä valinnaiset kentät' }}
            <svg class="inline-block w-4 h-4 ml-2 transform transition-transform duration-200" :class="{'rotate-90': showOptionalFields}" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"></path>
            </svg>
          </button>

          <div v-if="showOptionalFields" class="space-y-4 mt-4">
            <div class="space-y-1">
              <label for="result" class="inline-block text-sm font-medium">Tulos (pisteet/aika):</label>
              <input
                type="text"
                id="result"
                v-model="sessionForm.result"
                @input="formatNumberInput($event, 'result')"
                class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                placeholder="esim. 95/100, 12.34s"
              />
            </div>

            <div class="space-y-1">
              <label for="hitFactor" class="inline-block text-sm font-medium">Hit Factor (IPSC/IDPA):</label>
              <input
                type="text"
                id="hitFactor"
                v-model="sessionForm.hitFactor"
                @input="formatNumberInput($event, 'hitFactor')"
                class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                min="0"
              />
            </div>

            <div class="space-y-1">
              <label for="compScore" class="inline-block text-sm font-medium">Kilpailutulos (% parhaasta):</label>
              <input
                type="text"
                id="compscore"
                v-model="sessionForm.compScore"
                @input="formatNumberInput($event, 'compScore')"
                class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
                min="0"
                max="100"
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

            <div class="space-y-1">
              <label class="inline-block text-sm font-medium">Kuvat:</label>
              <p class="text-gray-400 text-sm">Kuvien lataustoiminto tulossa pian!</p>
              </div>
            <div class="space-y-1">
              <label class="inline-block text-sm font-medium">Allekirjoitus:</label>
              <p class="text-gray-400 text-sm">Allekirjoituksen piirtämis-/tallennustoiminto tulossa pian!</p>
              </div>
          </div>
        </div>

        <div v-if="errorMessage" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
          {{ errorMessage }}
        </div>

        <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
          <button
            type="submit"
            class="inline-flex w-full sm:w-auto items-center justify-center gap-2 rounded-lg border border-blue-700 bg-blue-700 px-6 py-3 leading-6 font-semibold text-white hover:border-blue-600 hover:bg-blue-600 focus:ring-3 focus:ring-blue-400/50 active:border-blue-700 active:bg-blue-700"
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
            <span>{{ loading ? 'Tallennetaan...' : (isEdit ? 'Päivitä istunto' : 'Kirjaa suoritus') }}</span> </button>
          <button
            type="button"
            @click="saveAsTemplate"
            class="inline-flex w-full sm:w-auto items-center justify-center gap-2 rounded-lg border border-gray-600 bg-gray-700 px-6 py-3 leading-6 font-semibold text-white hover:border-gray-500 hover:bg-gray-600 focus:ring-3 focus:ring-gray-400/50 active:border-gray-700 active:bg-gray-700"
            :disabled="loading || weaponsLoading || rangesLoading"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13.5h6m-3-3v6m-9 1V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18.75V7.5a2.25 2.25 0 012.25-2.25H9"></path>
            </svg>
            <span>Tallenna mallina</span>
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted, defineProps, defineEmits, watch, computed } from 'vue';
import { useSessions } from '../composables/useSessions';
import { useWeapons } from '../composables/useWeapons';
import { useApi } from '../composables/useApi';
import api from '../services/api';

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
  date: new Date().toISOString().split('T')[0], // fi-FI date format handled by toLocaleDateString for display
  rangeId: '',
  weaponId: '',
  numberOfShotsFired: 0,
  type: '',
  sportType: '',
  role: 'Ampuja',
  weather: '',
  ammunitionType: '',
  ammunitionCount: 0,
  distanceToTarget: null,
  hits: 0,
  misses: 0,
  notes: '',
  result: '',
  hitFactor: null,
  compScore: null,
  photos: [],
  signature: null,
});

const errorMessage = ref('');
const showOptionalFields = ref(false);

const sessionTypes = ref([
  'Kilpailu', 'Harjoitus', 'Harjoituskilpailu', 'Kuivaharjoittelu', 'Seuran viikkokisa', 'Valmennus', 'Muu merkintä'
]);

const roles = ref([
  'Ampuja', 'Valmentaja', 'Rata-ammunnan johtaja', 'Tuomari', 'Radanrakentaja', 'Muu rooli'
]);

const allSportTypes = {
  'Pistooli': ['25m isopistooli', 'Action Shooting', 'Cowboy Action Shooting', 'Falling plates', 'IDPA', 'IPSC', 'Kohdistus', 'Metsästys', 'Muu harjoittelu', 'Perinnepistooli 25m koulu', 'Perinnepistooli 25m kuvio', 'Perinnepistooli 50m', 'Practical', 'Precision Pistol', 'Reserviläisammunta 3', 'Reserviläisammunta 4', 'Siluettiammunta', 'Sovellettu perinneammunta', 'SRA'],
  'Kivääri': ['100m hirviammunta','300m kivääri 3x20','300m kivääri 3x40','300m kivääri makuu','300m vakiokivääri 3x20','Cowboy Action Shooting','Metsästys','Falling plates','Hirvenhiihto','IDPA','IPSC','SRA','Kaksoishirvi','Kasa-ammunta','Kenttäammunta','Kohdistus','Muu laji','Perinnekivääri 100m','Perinnekivääri 150m','Perinnekivääri 300m','RA 7','Precision Rifle Series','Reserviläisammunta 1','Reserviläisammunta 2','Tarkka-ammunta',],
  'Haulikko': ['Skeet', 'Trap', 'Kaksoistrap', 'Practical Shotgun', 'Sporting Clays', 'Muu'],
  'PCC': ['IPSC PCC', 'SRA', 'Muu'],
  'Revolveri': ['Precision Pistol', 'Action Shooting', 'Falling plates', 'IDPA', 'IPSC', 'Kohdistus', 'Metsästys', 'Perinnepistooli 25m koulu', 'Perinnepistooli 25m kuvio', 'Perinnepistooli 50m', 'Muu harjoittelu'],
  'Ilma-ase': ['Muu'], 
  'Deaktivoitu ampuma-ase': ['Muu'],
  'Yhdistelmäase': ['Muu'], 
  'Merkinantoase': ['Muu'],
  'Kaasuase': ['Muu'],
  'Muu': ['Muu']
};

const filteredSportTypes = computed(() => {
  if (!sessionForm.value.weaponId || !weapons.value.length) {
    return [];
  }
  const selectedWeapon = weapons.value.find(w => w._id === sessionForm.value.weaponId);
  if (selectedWeapon && selectedWeapon.type) {
    return allSportTypes[selectedWeapon.type] || allSportTypes['Other'];
  }
  return [];
});


const fetchRanges = async () => {
  rangesLoading.value = true;
  try {
    const responseData = await execute(api.get, '/api/ranges');
    ranges.value = responseData;
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
      type: props.initialSession.type || '',
      sportType: props.initialSession.sportType || '',
      role: props.initialSession.role || 'Ampuja',
      weather: props.initialSession.weather || '',
      result: props.initialSession.result || '',
      hitFactor: props.initialSession.hitFactor || null,
      compScore: props.initialSession.compScore || null,
      distanceToTarget: props.initialSession.distanceToTarget || null,
      notes: props.initialSession.notes || '',
      photos: props.initialSession.photos || [],
      signature: props.initialSession.signature || null,
    };
    if (props.initialSession.result || props.initialSession.hitFactor || props.initialSession.compScore || props.initialSession.distanceToTarget !== null || props.initialSession.notes || props.initialSession.photos.length > 0 || props.initialSession.signature) {
      showOptionalFields.value = true;
    }
  }
});

watch(() => sessionForm.value.weaponId, (newWeaponId) => {
  if (newWeaponId) {
    const selectedWeapon = weapons.value.find(w => w._id === newWeaponId);
    if (selectedWeapon && selectedWeapon.caliber) {
      sessionForm.value.ammunitionType = selectedWeapon.caliber;
    } else {
      sessionForm.value.ammunitionType = '';
    }
    sessionForm.value.sportType = '';
  } else {
    sessionForm.value.ammunitionType = '';
    sessionForm.value.sportType = '';
  }
}, { immediate: true });

watch(() => props.initialSession, (newVal) => {
  if (props.isEdit && newVal) {
    sessionForm.value = {
      ...newVal,
      date: new Date(newVal.date).toISOString().split('T')[0],
      rangeId: newVal.range?._id || '',
      type: newVal.type || '',
      sportType: newVal.sportType || '',
      role: newVal.role || 'Ampuja',
      weather: newVal.weather || '',
      result: newVal.result || '',
      hitFactor: newVal.hitFactor || null,
      compScore: newVal.compScore || null,
      distanceToTarget: newVal.distanceToTarget || null,
      notes: newVal.notes || '',
      photos: newVal.photos || [],
      signature: newVal.signature || null,
    };
    if (newVal.result || newVal.hitFactor || newVal.compScore || newVal.distanceToTarget !== null || newVal.notes || newVal.photos.length > 0 || newVal.signature) {
      showOptionalFields.value = true;
    }
  }
}, { immediate: true });

const formatNumberInput = (event, field) => {
  let value = event.target.value;
  value = value.replace(',', '.');
  const regex = /^-?\d*\.?\d{0,2}$/;
  if (!regex.test(value)) {
    event.target.value = sessionForm.value[field];
  } else {
    sessionForm.value[field] = value;
  }
};

const addShots = (amount) => {
  sessionForm.value.numberOfShotsFired = (sessionForm.value.numberOfShotsFired || 0) + amount;
};

const toggleOptionalFields = () => {
  showOptionalFields.value = !showOptionalFields.value;
};

const resetForm = (keepValues = false) => {
  const templateValues = keepValues ? { ...sessionForm.value } : {};
  sessionForm.value = {
    date: new Date().toISOString().split('T')[0],
    rangeId: templateValues.rangeId || '',
    weaponId: templateValues.weaponId || '',
    numberOfShotsFired: templateValues.numberOfShotsFired || 0,
    type: templateValues.type || '',
    sportType: templateValues.sportType || '',
    role: templateValues.role || 'Ampuja',
    weather: templateValues.weather || '',
    ammunitionType: templateValues.ammunitionType || '',
    ammunitionCount: templateValues.ammunitionCount || 0,
    distanceToTarget: templateValues.distanceToTarget || null,
    hits: templateValues.hits || 0,
    misses: templateValues.misses || 0,
    notes: templateValues.notes || '',
    result: templateValues.result || '',
    hitFactor: templateValues.hitFactor || null,
    compScore: templateValues.compScore || null,
    photos: [], // Always clear photos and signature for new session
    signature: null,
  };
  errorMessage.value = '';
  // showOptionalFields.value = false; // Optionally collapse after template save
};

const handleSubmit = async () => {
  errorMessage.value = '';
  if (!sessionForm.value.date || !sessionForm.value.rangeId || !sessionForm.value.weaponId || sessionForm.value.numberOfShotsFired === undefined || sessionForm.value.type === '' || sessionForm.value.sportType === '') {
    errorMessage.value = 'Täytä päivämäärä, ampumarata, ase, laukausten määrä, istunnon tyyppi ja laji.';
    return;
  }
  try {
    const payload = { ...sessionForm.value };
    payload.date = new Date(payload.date);
    payload.range = payload.rangeId;
    delete payload.rangeId;

    if (payload.distanceToTarget === '') payload.distanceToTarget = null;
    if (payload.hitFactor === '') payload.hitFactor = null;
    if (payload.compScore === '') payload.compScore = null;

    const savedSession = await createSession(payload);
    emit('session-saved', savedSession);
    resetForm(false); // Reset form completely after successful save and redirect  
  } catch (err) {
    errorMessage.value = err.message || 'Istunnon tallentaminen epäonnistui.';
  }
};

const saveAsTemplate = async () => {
  errorMessage.value = '';
  if (!sessionForm.value.date || !sessionForm.value.rangeId || !sessionForm.value.weaponId || sessionForm.value.numberOfShotsFired === undefined || sessionForm.value.type === '' || sessionForm.value.sportType === '') {
    errorMessage.value = 'Täytä kaikki pakolliset kentät tallentaaksesi mallina.';
    return;
  }
  try {
    const payload = { ...sessionForm.value };
    payload.date = new Date(payload.date);
    payload.range = payload.rangeId;
    delete payload.rangeId;

    if (payload.distanceToTarget === '') payload.distanceToTarget = null;
    if (payload.hitFactor === '') payload.hitFactor = null;
    if (payload.compScore === '') payload.compScore = null;

    const savedSession = await createSession(payload);
    // After saving, reset form but keep values as template
    resetForm(true);
    // Optionally, show a success message
    // emit('session-saved', savedSession); // Don't emit for redirect, just for success message
    errorMessage.value = 'Istunto tallennettu ja lomakkeen arvot kopioitu malliksi!'; // Success message
  } catch (err) {
    errorMessage.value = err.message || 'Mallin tallentaminen epäonnistui.';
  }
};

const goToAddRange = () => {
  router.push('/ranges/new');
};

</script>

<style scoped>
/* Scoped styles for this component */
</style>
