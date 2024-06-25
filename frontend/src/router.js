import { createRouter, createWebHistory } from 'vue-router';
import LandingPage from './views/LandingPage.vue';
import Home from './views/Home.vue';  // Make sure this file exists
import Profile from './views/Profile.vue';
import Sessions from './views/Sessions.vue';
import SessionList from './components/Session/SessionList.vue';
import NewSession from './components/Session/NewSession.vue';
import SessionDetail from './components/Session/SessionDetail.vue';
import Statistics from './views/Statistics.vue';
import Weapons from './views/Weapons.vue';
import Login from './components/Auth/Login.vue';
import Register from './components/Auth/Register.vue';

const routes = [
  { path: '/', component: LandingPage },
  { path: '/home', component: Home },
  { path: '/profile', component: Profile },
  { 
    path: '/sessions', 
    component: Sessions, 
    children: [
      { path: '', component: SessionList },
      { path: 'new', component: NewSession },
      { path: ':id', component: SessionDetail }
    ]
  },
  { path: '/statistics', component: Statistics },
  { path: '/weapons', component: Weapons },
  { path: '/login', component: Login },
  { path: '/register', component: Register },
  { path: '/:pathMatch(.*)*', redirect: '/' }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;