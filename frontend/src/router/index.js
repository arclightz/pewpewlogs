// frontend/src/router/index.js
import { createRouter, createWebHistory } from 'vue-router';
import authService from '../services/authService'; // Import your authService
import state from '../services/state'; // <-- CHANGE: Import your global state

// Import your views
import LandingPage from '../views/LandingPage.vue';
import Dashboard from '../views/Dashboard.vue';
import Login from '../views/Login.vue'; 
import Register from '../views/Register.vue'; 
import SessionList from '../views/SessionList.vue';
import CreateSession from '../views/CreateSession.vue';
import WeaponList from '../views/WeaponList.vue';
import CreateWeapon from '../views/CreateWeapon.vue';
import UserProfile from '../views/UserProfile.vue';
import Statistics from '../views/Statistics.vue';
import AddShootingRange from '../views/AddShootingRange.vue';
import ShootingRangeList from '../views/ShootingRangeList.vue'; 

const routes = [
  {
    path: '/',
    name: 'LandingPage',
    component: LandingPage,
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
  },
  {
    path: '/register',
    name: 'Register',
    component: Register,
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { requiresAuth: true }, // This route requires authentication
  },
  {
    path: '/sessions',
    name: 'SessionList',
    component: SessionList,
    meta: { requiresAuth: true },
  },
  {
    path: '/sessions/new',
    name: 'CreateSession',
    component: CreateSession,
    meta: { requiresAuth: true },
  },
  {
    path: '/weapons',
    name: 'WeaponList',
    component: WeaponList,
    meta: { requiresAuth: true },
  },
  {
    path: '/weapons/new',
    name: 'CreateWeapon',
    component: CreateWeapon,
    meta: { requiresAuth: true },
  },
  {
    path: '/profile',
    name: 'UserProfile',
    component: UserProfile,
    meta: { requiresAuth: true },
  },
  {
    path: '/statistics',
    name: 'Statistics',
    component: Statistics,
    meta: { requiresAuth: true },
  },
  {
    path: '/ranges', // This is the route in question
    name: 'ShootingRangeList',
    component: ShootingRangeList,
    meta: { requiresAuth: true },
  },
  {
    path: '/ranges/new',
    name: 'AddShootingRange',
    component: AddShootingRange,
    meta: { requiresAuth: true },
  },
  // Catch-all route for 404
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    redirect: '/', // Redirect to home or a dedicated 404 page
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

// Navigation Guard
router.beforeEach(async (to, from, next) => {
  // Attempt to fetch current user if state.user is null but a token exists
  // This handles page refreshes where App.vue might not have fully populated state.user yet
  if (!state.user && authService.isAuthenticated()) { // <-- CHANGE: Use state.user here
    try {
      await authService.fetchCurrentUser();
      console.log("[Router Guard] User fetched successfully.");
    } catch (error) {
      console.error("Error fetching current user on route navigation:", error);
      // If fetching user fails (e.g., invalid token), it will be logged out by authService
    }
  }

  const isAuthenticated = authService.isAuthenticated();
  console.log(`[Router Guard] Is Authenticated: ${isAuthenticated} for route ${to.path}`);

  // If the route requires authentication and the user is not authenticated, redirect to login
  if (to.meta.requiresAuth && !isAuthenticated) {
    next('/login');
  }
  // If trying to access login/register while already authenticated, redirect to dashboard
  else if ((to.name === 'Login' || to.name === 'Register') && isAuthenticated) {
    next('/dashboard');
  }
  // Otherwise, proceed
  else {
    next();
  }
});

export default router;
