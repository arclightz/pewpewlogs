<template>
    <div>
      <p>Loading...</p>
    </div>
  </template>
  
  <script>
  import { handleCallback } from "../services/authService";
  
  export default {
    async created() {
      await handleCallback();
      this.$router.push("/");
    },
  };
  </script>
  