<template>
    <div>
      <h2>Login</h2>
      <form @submit.prevent="login">
        <div>
          <label for="email">Email:</label>
          <input type="email" v-model="email" required>
        </div>
        <div>
          <label for="password">Password:</label>
          <input type="password" v-model="password" required>
        </div>
        <button type="submit">Login</button>
      </form>
    </div>
  </template>

  <script>
  import api from '../../services/api';

  export default {
    data() {
      return {
        email: '',
        password: ''
      };
    },
    methods: {
      login() {
        api.login({ email: this.email, password: this.password })
          .then(response => {
            // Handle successful login, store token, redirect, etc.
          })
          .catch(error => {
            // Handle error
            console.error(error);
          });
      }
    }
  };
  </script>