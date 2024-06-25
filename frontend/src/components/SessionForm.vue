<!-- src/components/SessionForm.vue -->
<template>
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div>
        <label for="date" class="block text-sm font-medium text-gray-700">Date</label>
        <input
          type="date"
          id="date"
          v-model="form.date"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="weaponId" class="block text-sm font-medium text-gray-700">Weapon</label>
        <select
          id="weaponId"
          v-model="form.weaponId"
          required
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
          <option v-for="weapon in weapons" :key="weapon.id" :value="weapon.id">
            {{ weapon.name }}
          </option>
        </select>
      </div>
  
      <div>
        <label for="duration" class="block text-sm font-medium text-gray-700">Duration (minutes)</label>
        <input
          type="number"
          id="duration"
          v-model="form.duration"
          required
          min="1"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
        >
      </div>
  
      <div>
        <label for="location" class="block text-sm font-medium text-gray-700">Location</label>
        <input
          type="text"
          id="location"
          v-model="form.location"
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
          {{ session ? 'Update' : 'Create' }} Session
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
        {{ isSubmitting ? 'Submitting...' : (session ? 'Update' : 'Create') + ' Session' }}
      </button>
    </div>
  </form>
  </template>
  
  <script>
  import { ref, onMounted } from 'vue';
  import { useWeapons } from '../composables/useWeapons';
  
  export default {
    props: {
      session: {
        type: Object,
        default: null
      }
    },
    emits: ['submit', 'cancel'],
    setup(props, { emit }) {
      const { getWeapons } = useWeapons();
      const weapons = ref([]);
      const form = ref({
        date: '',
        weaponId: '',
        duration: '',
        location: '',
        notes: ''
      });
      const errorMessage = ref('');
      const isSubmitting = ref(false);
  
      onMounted(async () => {
        try {
          weapons.value = await getWeapons();
          if (props.session) {
            form.value = { ...props.session };
          }
        } catch (error) {
          errorMessage.value = 'Failed to load weapons. Please try again.';
        }
      });
  
      const handleSubmit = async () => {
        errorMessage.value = '';
        isSubmitting.value = true;
        try {
          // Perform form validation
          if (!form.value.date || !form.value.weaponId || !form.value.duration) {
            throw new Error('Please fill in all required fields.');
          }
          emit('submit', form.value);
        } catch (error) {
          errorMessage.value = error.message || 'An error occurred. Please try again.';
        } finally {
          isSubmitting.value = false;
        }
      };
  
      return { form, weapons, handleSubmit, errorMessage, isSubmitting };
    }
  }
  </script>