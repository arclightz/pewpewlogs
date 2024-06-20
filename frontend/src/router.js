import Vue from 'vue';
import Router from 'vue-router';
import Home from './views/Home.vue';
import Profile from './views/Profile.vue';
import Sessions from './views/Sessions.vue';
import Statistics from './views/Statistics.vue';
import Weapons from './views/Weapons.vue';
import Login from './components/Auth/Login.vue';
import Register from './components/Auth/Register.vue';
import SessionList from './components/Session/SessionList.vue';
import SessionDetail from './components/Session/SessionDetail.vue';
import NewSession from './components/Session/NewSession.vue';
import ShotList from './components/Shot/ShotList.vue';
import NewShot from './components/Shot/NewShot.vue';

Vue.use(Router);

export default new Router({
  mode: 'history',
  routes: [
    { path: '/', component: Home },
    { path: '/profile', component: Profile },
    { path: '/sessions', component: Sessions, children: [
      { path: '', component: SessionList },
      { path: 'new', component: NewSession },
      { path: ':id', component: SessionDetail }
    ]},
    { path: '/statistics', component: Statistics },
    { path: '/weapons', component: Weapons },
    { path: '/login', component: Login },
    { path: '/register', component: Register },
    { path: '/sessions/:id/shots', component: ShotList },
    { path: '/sessions/:id/shots/new', component: NewShot }
  ]
});