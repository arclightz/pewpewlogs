<template>
    <div>
      <h2>Sessions</h2>
      <ul>
        <li v-for="session in sessions" :key="session.id">
          {{ session.name }}
        </li>
      </ul>
    </div>
  </template>
  
  <script>
  import { getSessions } from '../../services/api';
  
  export default {
    data() {
      return {
        sessions: [],
      };
    },
    created() {
      getSessions()
        .then(response => {
          this.sessions = response.data;
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