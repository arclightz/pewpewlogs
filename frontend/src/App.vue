<template>
  <div class="min-h-screen bg-blue-900 text-white">
    <TopNavBar />
    <main class="container mx-auto px-4 py-8">
      <div v-if="isLoading" class="flex justify-center items-center h-64">
        <p>Loading application...</p>
      </div>
      <router-view v-else></router-view>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import TopNavBar from './components/TopNavBar.vue';
import state from './services/state'; // Assuming this is your global reactive state
import { useRouter } from 'vue-router';

const router = useRouter();
const user = ref(null); // Local ref to hold the user object
const isLoading = ref(true); // Reactive state to manage loading status

// Computed property to check if the user is authenticated
// Now checks for the presence of a token in localStorage
const isAuthenticated = computed(() => {
  return !!localStorage.getItem('token'); // Check if a token exists
});

/**
 * Checks the current authentication status by looking for a JWT token.
 * Updates the global state and local user ref based on token presence.
 * This function will primarily determine if a user *might* be logged in.
 * Actual user data (e.g., user ID, name) would typically be fetched after login
 * and stored in `state.user`.
 */
const checkAuthentication = async () => {
  try {
    // In a JWT flow, the user data is usually decoded from the token
    // or fetched from a /api/auth/me endpoint after the token is set.
    // For this App.vue, we're simply checking if a token exists.
    const token = localStorage.getItem('token');

    if (token) {
      // If a token exists, assume the user is authenticated for UI purposes.
      // The actual user object (e.g., { id: '...', name: '...' }) would be set
      // by your login component after a successful API call.
      // For now, we'll just set a placeholder or rely on `state.user` being set elsewhere.
      // If `state.user` is not populated by a login component, you might need
      // a dedicated API call here to fetch user details.
      // Example: const currentUser = await fetch('/api/auth/me', { headers: { 'x-auth-token': token } }).then(res => res.json());
      // state.user = currentUser;
      // user.value = currentUser;

      // For the purpose of just indicating "logged in", we can set a dummy user
      // or rely on a different part of the app to populate `state.user` after login.
      // Let's assume `state.user` will be populated by the login view.
      user.value = { isAuthenticated: true }; // Simple indicator
    } else {
      user.value = null; // No token, no user
    }

    // No longer need to check for 'code=' in the URL for Kinde callback.
    // Routing to dashboard after login will be handled by the login component itself.
    // If the user lands on the root and is authenticated, you might want to redirect them.
    if (isAuthenticated.value && router.currentRoute.value.path === '/') {
       router.push('/dashboard');
    }

  } catch (error) {
    console.error('Error during authentication check:', error);
    // Handle error, e.g., clear token if it's invalid
    localStorage.removeItem('token');
  } finally {
    isLoading.value = false; // Always set loading to false once check is done
  }
};

// Lifecycle hook: executed after the component is mounted
onMounted(async () => {
  // Directly check authentication status based on JWT token presence.
  // No special handling for OIDC redirect 'code=' needed anymore.
  await checkAuthentication();
});
</script>

<style scoped>
/* Add any component-specific styles here if needed */
/* Tailwind CSS classes are primarily used for styling */
</style>
