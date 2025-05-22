// frontend/src/main.js
import { createApp } from 'vue'; // Import the createApp function from Vue
import App from './App.vue'; // Import the root App component
import router from './router'; // Import your Vue Router instance
import './style.css'; // Import your main CSS file (e.g., for global styles or Tailwind directives)
import './assets/tailwind.css'; // Assuming you have a dedicated Tailwind CSS file for imports

// Create the Vue application instance
const app = createApp(App);

// Use the router plugin with the Vue app
// This makes the router instance available throughout your app via `useRouter()`
app.use(router);

// Mount the Vue application to the DOM element with the ID 'app'
// This is typically defined in your index.html file.
app.mount('#app');

console.log('Vue application mounted successfully!');
