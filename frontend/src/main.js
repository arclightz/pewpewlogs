// frontend/src/main.js
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import './style.css'; 
import './assets/tailwind.css';
import 'leaflet/dist/leaflet.css';

// Create the Vue application instance
const app = createApp(App);

// Use the router plugin with the Vue app
// This makes the router instance available throughout your app via `useRouter()`
app.use(router);

// Mount the Vue application to the DOM element with the ID 'app'
// This is typically defined in your index.html file.
app.mount('#app');

console.log('Vue application mounted successfully!');
