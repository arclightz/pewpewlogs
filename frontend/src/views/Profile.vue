<template>
    <div>
      <h1>Profile</h1>
      <p>User profile details go here</p>
    </div>
  </template>
  
  <script>
  import { getUserDetails, updateUserDetails } from '../services/api';
  
  export default {
    data() {
      return {
        user: {},
      };
    },
    created() {
      getUserDetails()
        .then(response => {
          this.user = response.data;
        })
        .catch(error => {
          // Handle error
        });
    },
    methods: {
      updateProfile() {
        updateUserDetails(this.user)
          .then(response => {
            // Handle successful update
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