import './assets/tailwind.css';
import { createApp } from 'vue';
import App from './App.vue';
import router from './router/index';
import { initializeKinde } from './services/kinde';
import state from './services/state';

console.log('Main.js is running');

(async () => {
  const kinde = await initializeKinde();

  const app = createApp(App);
  app.use(router);

  // Make Kinde available globally
  app.config.globalProperties.$kinde = kinde;
  app.config.globalProperties.$state = state;

  app.mount('#app');
})();
