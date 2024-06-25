import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

console.log('Main.js is running')

const app = createApp(App)
app.use(router)
app.mount('#app')