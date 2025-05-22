<template>
  <form @submit.prevent="handleSubmit" class="bg-blue-800 p-8 rounded-lg shadow-xl w-full max-w-xl text-white">
    <h2 class="text-2xl font-bold mb-6 text-center">{{ isEdit ? 'Edit Weapon' : 'Add New Weapon' }}</h2>

    <div class="mb-4">
      <label for="name" class="block text-blue-200 text-sm font-bold mb-2">Weapon Name:</label>
      <input
        type="text"
        id="name"
        v-model="weaponForm.name"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        placeholder="e.g., Glock 19, AR-15"
        required
      />
    </div>

    <div class="mb-6">
      <label for="type" class="block text-blue-200 text-sm font-bold mb-2">Weapon Type:</label>
      <input
        type="text"
        id="type"
        v-model="weaponForm.type"
        class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-800 leading-tight focus:outline-none focus:shadow-outline"
        placeholder="e.g., Pistol, Rifle, Shotgun"
      />
    </div>

    <div v-if="errorMessage" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
      <span class="block sm:inline">{{ errorMessage }}</span>
    </div>

    <div class="flex items-center justify-between">
      <button
        type="submit"
        class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full"
        :disabled="loading"
      >
        {{ loading ? 'Saving...' : (isEdit ? 'Update Weapon' : 'Add Weapon') }}
      </button>
    </div>
  </form>
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
  // Add other MVP fields here
});

const errorMessage = ref('');

// Watch for changes in initialWeapon if it's loaded asynchronously
watch(() => props.initialWeapon, (newVal) => {
  if (props.isEdit && newVal) {
    weaponForm.value = { ...newVal };
  }
}, { immediate: true });

const handleSubmit = async () => {
  errorMessage.value = '';
  try {
    // For MVP, we're only implementing create.
    // If isEdit is true, you'd call an updateWeapon function here.
    const savedWeapon = await createWeapon(weaponForm.value);
    emit('weapon-saved', savedWeapon); // Emit event to parent
    // Reset form after successful submission
    weaponForm.value = {
      name: '',
      type: '',
    };
  } catch (err) {
    errorMessage.value = err.message || 'Failed to save weapon.';
  }
};
</script>

<style scoped>
/* Scoped styles for this component */
</style>
