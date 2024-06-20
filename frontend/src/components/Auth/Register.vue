<template>
    <div>
      <h2>Register</h2>
      <form @submit.prevent="register">
        <div>
          <label for="email">Email:</label>
          <input type="email" v-model="email" required>
        </div>
        <div>
          <label for="password">Password:</label>
          <input type="password" v-model="password" required>
        </div>
        <button type="submit">Register</button>
      </form>
    </div>
  </template>
  
  <script>
  import { register } from '../../services/api';
  
  export default {
    data() {
      return {
        email: '',
        password: '',
      };
    },
    methods: {
      register() {
        register({ email: this.email, password: this.password })
          .then(response => {
            // Handle successful registration
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