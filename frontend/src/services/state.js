// frontend/src/services/state.js
import { reactive } from 'vue';

const state = reactive({
  user: null, // This will hold the user object { id, name, email } when logged in
});

export default state;