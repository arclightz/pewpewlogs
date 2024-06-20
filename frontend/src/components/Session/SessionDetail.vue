<template>
    <div>
      <h2>Session Details</h2>
      <div v-if="session">
        <p>{{ session.name }}</p>
        <!-- Add more session details here -->
      </div>
    </div>
  </template>
  
  <script>
  import { getSession } from '../../services/api';
  
  export default {
    data() {
      return {
        session: null,
      };
    },
    created() {
      const sessionId = this.$route.params.id;
      getSession(sessionId)
        .then(response => {
          this.session = response.data;
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