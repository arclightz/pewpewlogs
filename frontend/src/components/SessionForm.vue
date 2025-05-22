<template>
  <form @submit.prevent="handleSubmit" class="bg-blue-800 p-8 rounded-lg shadow-xl w-full max-w-xl text-white">
    <h2 class="text-2xl font-bold mb-6 text-center">{{ isEdit ? 'Edit Session' : 'Log New Session' }}</h2>

    <div class="mb-4">
      <label for="date" class="block text-blue-200 text-sm font-bold mb-2">Date:</label>
      <input
        type="date"
        id="date"
        v-model="sessionForm.date"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        required
      />
    </div>

    <div class="mb-4">
      <label for="location" class="block text-blue-200 text-sm font-bold mb-2">Location:</label>
      <input
        type="text"
        id="location"
        v-model="sessionForm.location"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        placeholder="e.g., Local Range, Outdoor Field"
        required
      />
    </div>

    <div class="mb-4">
      <label for="weapon" class="block text-blue-200 text-sm font-bold mb-2">Weapon Used:</label>
      <select
        id="weapon"
        v-model="sessionForm.weaponId"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        required
      >
        <option value="" disabled>Select a weapon</option>
        <option v-for="weapon in weapons" :key="weapon._id" :value="weapon._id">
          {{ weapon.name }} ({{ weapon.type }})
        </option>
      </select>
      <p v-if="weaponsLoading" class="text-blue-300 text-sm mt-1">Loading weapons...</p>
      <p v-if="weaponsError" class="text-red-400 text-sm mt-1">Error loading weapons: {{ weaponsError }}</p>
      <p v-if="weapons.length === 0 && !weaponsLoading" class="text-blue-300 text-sm mt-1">
        No weapons found. Please <router-link to="/weapons/new" class="underline">add a weapon</router-link> first.
      </p>
    </div>

    <div class="mb-4">
      <label for="ammunitionType" class="block text-blue-200 text-sm font-bold mb-2">Ammunition Type:</label>
      <input
        type="text"
        id="ammunitionType"
        v-model="sessionForm.ammunitionType"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        placeholder="e.g., 9mm FMJ, .22LR"
      />
    </div>

    <div class="mb-4">
      <label for="ammunitionCount" class="block text-blue-200 text-sm font-bold mb-2">Ammunition Count:</label>
      <input
        type="number"
        id="ammunitionCount"
        v-model.number="sessionForm.ammunitionCount"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        min="0"
      />
    </div>

    <div class="mb-4">
      <label for="shotsFired" class="block text-blue-200 text-sm font-bold mb-2">Number of Shots Fired:</label>
      <input
        type="number"
        id="shotsFired"
        v-model.number="sessionForm.numberOfShotsFired"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        min="0"
      />
    </div>

    <div class="mb-4">
      <label for="distance" class="block text-blue-200 text-sm font-bold mb-2">Distance to Target (meters):</label>
      <input
        type="number"
        id="distance"
        v-model.number="sessionForm.distanceToTarget"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        min="0"
      />
    </div>

    <div class="mb-4 flex space-x-4">
      <div class="flex-1">
        <label for="hits" class="block text-blue-200 text-sm font-bold mb-2">Hits:</label>
        <input
          type="number"
          id="hits"
          v-model.number="sessionForm.hits"
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
          min="0"
        />
      </div>
      <div class="flex-1">
        <label for="misses" class="block text-blue-200 text-sm font-bold mb-2">Misses:</label>
        <input
          type="number"
          id="misses"
          v-model.number="sessionForm.misses"
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
          min="0"
        />
      </div>
    </div>

    <div class="mb-6">
      <label for="notes" class="block text-blue-200 text-sm font-bold mb-2">Session Notes:</label>
      <textarea
        id="notes"
        v-model="sessionForm.notes"
        rows="3"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        placeholder="Add any observations or details about this session..."
      ></textarea>
    </div>

    <div v-if="errorMessage" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ errorMessage }}</span>
    </div>

    <div class="flex items-center justify-between">
      <button
        type="submit"
        class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full"
        :disabled="loading || weaponsLoading"
      >
        {{ loading ? 'Saving...' : (isEdit ? 'Update Session' : 'Log Session') }}
      </button>
    </div>
  </form>
</template>

<script setup>
import { ref, onMounted, defineProps, defineEmits, watch } from 'vue';
import { useSessions } from '../composables/useSessions';
import { useWeapons } from '../composables/useWeapons'; // To get list of weapons

const props = defineProps({
  initialSession: {
    type: Object,
    default: null, // For editing an existing session
  },
  isEdit: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['session-saved']);

const { createSession, loading, error } = useSessions();
const { weapons, loading: weaponsLoading, error: weaponsError, fetchWeapons } = useWeapons();

const sessionForm = ref({
  date: new Date().toISOString().split('T')[0], // Default to today's date
  location: '',
  weaponId: '', // Will store the _id of the selected weapon
  ammunitionType: '',
  ammunitionCount: 0,
  numberOfShotsFired: 0,
  distanceToTarget: 0,
  hits: 0,
  misses: 0,
  notes: '',
});

const errorMessage = ref('');

onMounted(() => {
  fetchWeapons(); // Fetch available weapons when the form mounts

  if (props.isEdit && props.initialSession) {
    // Populate form for editing
    sessionForm.value = {
      ...props.initialSession,
      date: new Date(props.initialSession.date).toISOString().split('T')[0], // Format date for input
      weaponId: props.initialSession.weapon?._id || '', // Ensure weaponId is set if weapon object exists
    };
  }
});

// Watch for changes in initialSession if it's loaded asynchronously
watch(() => props.initialSession, (newVal) => {
  if (props.isEdit && newVal) {
    sessionForm.value = {
      ...newVal,
      date: new Date(newVal.date).toISOString().split('T')[0],
      weaponId: newVal.weapon?._id || '',
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  errorMessage.value = '';
  try {
    // For MVP, we're only implementing create.
    // If isEdit is true, you'd call an updateSession function here.
    const payload = { ...sessionForm.value };
    // Convert date string to Date object for backend
    payload.date = new Date(payload.date);

    const savedSession = await createSession(payload);
    emit('session-saved', savedSession); // Emit event to parent
    // Reset form after successful submission
    sessionForm.value = {
      date: new Date().toISOString().split('T')[0],
      location: '',
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
    errorMessage.value = err.message || 'Failed to save session.';
  }
};
</script>

<style scoped>
/* Scoped styles for this component */
</style>
