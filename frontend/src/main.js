import './assets/tailwind.css'  // or wherever your main CSS file is located
import { createApp } from 'vue'
import App from './App.vue'
import router from './router/index'
import { KindeVue } from '@kinde-oss/kinde-auth-vue'

console.log('Main.js is running')

const app = createApp(App)
app.use(router)
app.use(KindeVue, {
    clientId: process.env.VUE_APP_KINDE_CLIENT_ID,
    domain: process.env.VUE_APP_KINDE_DOMAIN,
    redirectUri: process.env.VUE_APP_KINDE_REDIRECT_URI,
    logoutRedirectUri: process.env.VUE_APP_KINDE_LOGOUT_REDIRECT_URI
  })
app.mount('#app')