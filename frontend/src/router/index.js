import { createRouter, createWebHistory } from 'vue-router';
import { useKindeAuth } from '@kinde-oss/kinde-auth-vue'

import LandingPage from './views/LandingPage.vue';
import LandingPage from '../views/LandingPage.vue'
import Dashboard from '../views/Dashboard.vue'
import SessionList from '../views/SessionList.vue'
import WeaponList from '../views/WeaponList.vue'
import Statistics from '../views/Statistics.vue'

const routes = [
  { path: '/', component: LandingPage },
  { path: '/dashboard', component: Dashboard, meta: { requiresAuth: true } },
  { path: '/sessions', component: SessionList, meta: { requiresAuth: true } },
  { path: '/weapons', component: WeaponList, meta: { requiresAuth: true } },
  { path: '/stats', component: Statistics, meta: { requiresAuth: true } },
  { path: '/callback', component: { template: '<div>Processing login...</div>' } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to, from, next) => {
  const { isAuthenticated } = useKindeAuth()
  
  if (to.meta.requiresAuth && !isAuthenticated.value) {
    next('/')
  } else {
    next()
  }
})

export default router