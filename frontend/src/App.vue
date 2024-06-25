<template>
  <div id="app">
    <h1>PewPewLogs App</h1>
    <router-view></router-view>
    <RouterLink to="/">Go to Landing Page</RouterLink>
  </div>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>