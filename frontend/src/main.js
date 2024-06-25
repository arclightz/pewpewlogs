import './assets/tailwind.css'; // or wherever your main CSS file is located
import { createApp } from 'vue';
import App from './App.vue';
import router from './router/index';

console.log('Main.js is running');

const app = createApp(App);
app.use(router);
app.mount('#app');