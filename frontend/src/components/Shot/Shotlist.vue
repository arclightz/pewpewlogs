<template>
    <div>
      <h2>Shots</h2>
      <ul>
        <li v-for="shot in shots" :key="shot.id">
          {{ shot.detail }}
        </li>
      </ul>
    </div>
  </template>

  <script>
  import { getShots } from '../../services/api';

  export default {
    data() {
      return {
        shots: [],
      };
    },
    created() {
      const sessionId = this.$route.params.id;
      getShots(sessionId)
        .then(response => {
          this.shots = response.data;
        })
        .catch(error => {
          // Handle error
        });
    },
  };
  </script>
  
  <style scoped>
  /* Add your styles here */
  </style>