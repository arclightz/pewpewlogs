<template>
    <div
      v-if="message"
      :class="[
        'fixed top-4 right-4 px-4 py-2 rounded-md shadow-lg max-w-sm z-50 transition-all duration-500 ease-in-out',
        type === 'success' ? 'bg-green-500 text-white' : 'bg-red-500 text-white'
      ]"
    >
      <div class="flex items-center">
        <svg
          v-if="type === 'success'"
          class="w-6 h-6 mr-2"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
        <svg
          v-else
          class="w-6 h-6 mr-2"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
        </svg>
        <span>{{ message }}</span>
      </div>
    </div>
  </template>
  
  <script>
  import { ref, watch } from 'vue';
  
  export default {
    props: {
      message: String,
      type: {
        type: String,
        default: 'success',
        validator: (value) => ['success', 'error'].includes(value),
      },
      duration: {
        type: Number,
        default: 3000,
      },
    },
    emits: ['close'],
    setup(props, { emit }) {
      const isVisible = ref(true);
  
      watch(() => props.message, () => {
        if (props.message) {
          isVisible.value = true;
          setTimeout(() => {
            isVisible.value = false;
            emit('close');
          }, props.duration);
        }
      });
  
      return { isVisible };
    },
  };
  </script>