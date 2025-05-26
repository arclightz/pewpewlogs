<template>
  <div class="px-4 py-8 lg:px-8 lg:py-16 w-full min-h-full"> <form @submit.prevent="handleSubmit" class="bg-gray-800 p-8 rounded-lg shadow-xl w-full max-w-xl mx-auto text-gray-100">
      <h2 class="text-2xl font-bold mb-6 text-center">{{ isEdit ? 'Edit Weapon' : 'Add New Weapon' }}</h2>

      <div class="space-y-4">
        <div class="space-y-1">
          <label for="name" class="inline-block text-sm font-medium">Weapon Name:</label>
          <input
            type="text"
            id="name"
            v-model="weaponForm.name"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            placeholder="e.g., Glock 19, AR-15"
            required
          />
        </div>

        <div class="space-y-1">
          <label for="type" class="inline-block text-sm font-medium">Weapon Type:</label>
          <select
            id="type"
            v-model="weaponForm.type"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            required
          >
            <option value="" disabled selected>Select a weapon type</option>
            <option v-for="typeOption in weaponTypes" :key="typeOption" :value="typeOption">{{ typeOption }}</option>
          </select>
        </div>

        <div class="space-y-1">
          <label for="caliber" class="inline-block text-sm font-medium">Caliber:</label>
          <select
            id="caliber"
            v-model="weaponForm.caliber"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
          >
            <option value="" disabled selected>Select a caliber (optional)</option>
            <option v-for="caliberOption in calibers" :key="caliberOption" :value="caliberOption">{{ caliberOption }}</option>
          </select>
        </div>

        <div class="space-y-1">
          <label for="purchaseDate" class="inline-block text-sm font-medium">Purchase Date:</label>
          <input
            type="date"
            id="purchaseDate"
            v-model="weaponForm.purchaseDate"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
          />
        </div>

        <div class="flex items-center">
          <input
            type="checkbox"
            id="erva"
            v-model="weaponForm.erva"
            class="size-4 rounded-sm border border-gray-600 text-blue-500 checked:border-blue-500 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 dark:ring-offset-gray-900"
          />
          <label for="erva" class="ml-2 text-sm font-medium">ERVA (Eligible for Restricted Veteran Activities)</label>
        </div>

        <div class="space-y-1">
          <label for="notes" class="inline-block text-sm font-medium">Notes:</label>
          <textarea
            id="notes"
            v-model="weaponForm.notes"
            rows="3"
            class="block w-full rounded-lg border border-gray-600 px-5 py-3 leading-6 placeholder-gray-400 focus:border-blue-500 focus:ring-3 focus:ring-blue-500/50 bg-gray-700 text-gray-100"
            placeholder="Any additional notes about this weapon..."
          ></textarea>
        </div>

        <div v-if="errorMessage" class="bg-red-800 text-white px-4 py-3 rounded relative text-sm" role="alert">
          {{ errorMessage }}
        </div>

        <div>
          <button
            type="submit"
            class="inline-flex w-full items-center justify-center gap-2 rounded-lg border border-blue-700 bg-blue-700 px-6 py-3 leading-6 font-semibold text-white hover:border-blue-600 hover:bg-blue-600 focus:ring-3 focus:ring-blue-400/50 active:border-blue-700 active:bg-blue-700"
            :disabled="loading"
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
            <span>{{ loading ? 'Saving...' : (isEdit ? 'Update Weapon' : 'Add Weapon') }}</span>
          </button>
        </div>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, defineProps, defineEmits, watch } from 'vue';
import { useWeapons } from '../composables/useWeapons';

const props = defineProps({
  initialWeapon: {
    type: Object,
    default: null, // For editing an existing weapon
  },
  isEdit: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['weapon-saved']);

const { createWeapon, loading, error } = useWeapons();

const weaponForm = ref({
  name: '',
  type: '',
  caliber: '',
  erva: false,
  purchaseDate: '', // Will be a string in 'YYYY-MM-DD' format
  notes: '',
});

const errorMessage = ref('');

// Predefined lists for dropdowns
const weaponTypes = ref([
  'Pistooli', 'Kivääri', 'Haulikko', 'Revolveri', 'PCC', 'Ilma-ase', 
  'Deaktivoitu ampuma-ase','Muu','Yhdistelmäase', 'Merkinantoase', 'Kaasuase' 
]);

const calibers = ref([
  '9mm', '.45 ACP', '.22LR', '.223 Rem (5.56x45mm)', '7.62x39mm', '7.62x51mm (.308 Win)',
  '.50 BMG', '12 Gauge', '.357 Magnum', '.38 Special', '.40 S&W', '10mm Auto', 'Muu kaliberi'
]);

// Watch for changes in initialWeapon if it's loaded asynchronously
watch(() => props.initialWeapon, (newVal) => {
  if (props.isEdit && newVal) {
    weaponForm.value = {
      ...newVal,
      purchaseDate: newVal.purchaseDate ? new Date(newVal.purchaseDate).toISOString().split('T')[0] : '',
    };
  }
}, { immediate: true });

const handleSubmit = async () => {
  errorMessage.value = '';
  try {
    const payload = { ...weaponForm.value };
    if (payload.purchaseDate) {
      payload.purchaseDate = new Date(payload.purchaseDate);
    } else {
      delete payload.purchaseDate;
    }

    const savedWeapon = await createWeapon(payload);
    emit('weapon-saved', savedWeapon);
    // Reset form after successful submission
    weaponForm.value = {
      name: '',
      type: '',
      caliber: '',
      erva: false,
      purchaseDate: '',
      notes: '',
    };
  } catch (err) {
    errorMessage.value = err.message || 'Failed to save weapon.';
  }
};
</script>

<style scoped>
/* No specific scoped styles needed if using Tailwind's active-class */
</style>