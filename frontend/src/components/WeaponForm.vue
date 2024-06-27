<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <div v-for="field in formFields" :key="field.id">
      <label :for="field.id" class="block text-sm font-medium text-gray-700">{{ field.label }}</label>
      <input
        v-if="field.type !== 'textarea'"
        :type="field.type"
        :id="field.id"
        v-model="form[field.id]"
        :required="field.required"
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 text-gray-900"
      >
      <textarea
        v-else
        :id="field.id"
        v-model="form[field.id]"
        rows="3"
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 text-gray-900"
      ></textarea>
    </div>

    <div class="flex justify-end space-x-3">
      <button
        type="button"
        @click="$emit('cancel')"
        class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        :disabled="isSubmitting"
      >
        Cancel
      </button>
      <button
        type="submit"
        class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        :disabled="isSubmitting"
      >
        {{ isSubmitting ? 'Submitting...' : (weapon ? 'Update' : 'Create') + ' Weapon' }}
      </button>
    </div>
    
    <div v-if="errorMessage" class="text-red-500 text-sm mt-2">
      {{ errorMessage }}
    </div>
  </form>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const props = defineProps({
  weapon: {
    type: Object,
    default: null
  }
});

const emit = defineEmits(['submit', 'cancel']);

const formFields = [
  { id: 'name', label: 'Name', type: 'text', required: true },
  { id: 'type', label: 'Type', type: 'text', required: true },
  { id: 'caliber', label: 'Caliber', type: 'text', required: false },
  { id: 'erva', label: 'ERVA', type: 'text', required: false },
  { id: 'purchaseDate', label: 'Purchase Date', type: 'date', required: false },
  { id: 'notes', label: 'Notes', type: 'textarea', required: false },
];

const form = ref({
  name: '',
  type: '',
  caliber: '',
  erva: '',
  purchaseDate: '',
  notes: ''
});

const errorMessage = ref('');
const isSubmitting = ref(false);

onMounted(() => {
  if (props.weapon) {
    form.value = { ...props.weapon };
  }
});

const handleSubmit = async () => {
  errorMessage.value = '';
  isSubmitting.value = true;
  try {
    if (!form.value.name || !form.value.type) {
      throw new Error('Please fill in all required fields.');
    }
    emit('submit', form.value);
  } catch (error) {
    errorMessage.value = error.message || 'An error occurred. Please try again.';
  } finally {
    isSubmitting.value = false;
  }
};
</script>