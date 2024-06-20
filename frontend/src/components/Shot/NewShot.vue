<template>
    <div>
      <h2>New Shot</h2>
      <form @submit.prevent="addShot">
        <div>
          <label for="detail">Shot Detail:</label>
          <input type="text" v-model="detail" required>
        </div>
        <button type="submit">Add Shot</button>
      </form>
    </div>
  </template>

  <script>
  import { addShots } from '../../services/api';

  export default {
    data() {
      return {
        detail: '',
      };
    },
    methods: {
      addShot() {
        const sessionId = this.$route.params.id;
        addShots(sessionId, { detail: this.detail })
          .then(response => {
            // Handle successful shot addition
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