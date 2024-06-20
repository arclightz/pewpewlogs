<template>
    <div>
      <h2>New Session</h2>
      <form @submit.prevent="createSession">
        <div>
          <label for="name">Session Name:</label>
          <input type="text" v-model="name" required>
        </div>
        <button type="submit">Create</button>
      </form>
    </div>
  </template>
  
  <script>
  import { createSession } from '../../services/api';
  
  export default {
    data() {
      return {
        name: '',
      };
    },
    methods: {
      createSession() {
        createSession({ name: this.name })
          .then(response => {
            // Handle successful creation
          })
          .catch(error => {
            // Handle error
          });
      },
    },
  };
  </script>
  
  <style scoped>
  /* Add your styles here */
  </style>