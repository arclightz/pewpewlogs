<template>
    <div>
      <h1>Statistics</h1>
      <p>Analytics and statistics go here</p>
    </div>
  </template>
  
  <script>
  import { getSessionStats, getShootingStats } from '../services/api';
  
  export default {
    data() {
      return {
        sessionStats: {},
        shootingStats: {},
      };
    },
    created() {
      getSessionStats()
        .then(response => {
          this.sessionStats = response.data;
        })
        .catch(error => {
          // Handle error
        });
  
      getShootingStats()
        .then(response => {
          this.shootingStats = response.data;
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