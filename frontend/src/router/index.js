import { createRouter, createWebHistory } from 'vue-router';

import LandingPage from '../views/LandingPage.vue'
import Dashboard from '../views/Dashboard.vue'
import SessionList from '../views/SessionList.vue'
import WeaponList from '../views/WeaponList.vue'
import Statistics from '../views/Statistics.vue'
import AuthCallback from "../components/AuthCallback.vue";
import { getUser } from "../services/authService";

const routes = [
  { path: '/', component: LandingPage },
  { path: '/dashboard', component: Dashboard, meta: { requiresAuth: true } },
  { path: '/sessions', component: SessionList, meta: { requiresAuth: true } },
  { path: '/weapons', component: WeaponList, meta: { requiresAuth: true } },
  { path: '/stats', component: Statistics, meta: { requiresAuth: true } },
  { path: '/callback', name: "Callback", component: AuthCallback },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to, from, next) => {
  const user = await getUser();
  
  if (to.meta.requiresAuth && !user) {
    next('/');
  } else {
    next();
  }
});

export default router