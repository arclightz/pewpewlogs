<!-- src/components/WeaponForm.vue -->
<template>
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div>
        <label for="name" class="block text-sm font-medium text-gray-700">Name</label>
        <input
          type="text"
          id="name"
          v-model="form.name"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="type" class="block text-sm font-medium text-gray-700">Type</label>
        <input
          type="text"
          id="type"
          v-model="form.type"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="caliber" class="block text-sm font-medium text-gray-700">Caliber</label>
        <input
          type="text"
          id="caliber"
          v-model="form.caliber"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="erva" class="block text-sm font-medium text-gray-700">ERVA</label>
        <input
          type="text"
          id="erva"
          v-model="form.erva"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="purchaseDate" class="block text-sm font-medium text-gray-700">Purchase Date</label>
        <input
          type="date"
          id="purchaseDate"
          v-model="form.purchaseDate"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="notes" class="block text-sm font-medium text-gray-700">Notes</label>
        <textarea
          id="notes"
          v-model="form.notes"
          rows="3"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        ></textarea>
      </div>
  
      <div class="flex justify-end space-x-3">
        <button
          type="button"
          @click="$emit('cancel')"
          class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          Cancel
        </button>
        <button
          type="submit"
          class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          {{ weapon ? 'Update' : 'Create' }} Weapon
        </button>
      </div>
      <div v-if="errorMessage" class="text-red-500 text-sm mt-2">
      {{ errorMessage }}
    </div>

    <div class="flex justify-end space-x-3">
      <button
        type="button"
        @click="$emit('cancel')"
        class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
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
    </form>
  </template>
  
  <script>
  import { ref, onMounted } from 'vue';
  
  export default {
    props: {
      weapon: {
        type: Object,
        default: null
      }
    },
    emits: ['submit', 'cancel'],
    setup(props, { emit }) {
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
          // Perform form validation
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
  
      return { form, handleSubmit, errorMessage, isSubmitting };
    }
  }
  </script>