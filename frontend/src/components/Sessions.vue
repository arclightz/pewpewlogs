<script setup>
import { ref, onMounted } from 'vue';
import { getSessions } from '../services/api';

const sessions = ref([]);
const loading = ref(true);
const error = ref(null);

const fetchSessions = async () => {
  try {
    loading.value = true;
    const response = await getSessions();
    sessions.value = response.data;
  } catch (err) {
    error.value = 'Error loading sessions: ' + err.message;
  } finally {
    loading.value = false;
  }
};

onMounted(fetchSessions);
</script>