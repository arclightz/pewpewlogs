import router from './router';
import './assets/tailwind.css'
import { createApp } from 'vue'
import './style.css'
import App from './Home.vue'

Vue.config.productionTip = false;

new Vue({
    router,
    render: h => h(App),
    }).$mount('#app');
