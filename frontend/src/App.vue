<template>
  <div id="app">
    <router-view></router-view>
    <RouterLink to="/">Go to Landing Page</RouterLink>
  </div>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>