<!-- src/views/SessionList.vue -->
<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Shooting Sessions</h1>
    
    <button
      @click="showNewSessionForm = true"
      class="mb-4 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
    >
      New Session
    </button>

    <div v-if="loading" class="text-center py-4">
      <p class="text-gray-600">Loading sessions...</p>
    </div>

    <div v-else-if="error" class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4" role="alert">
      <p>Error loading sessions: {{ error }}</p>
    </div>

    <div v-else>
      <div v-for="session in sessions" :key="session.id" class="bg-white shadow rounded-lg p-6 mb-4">
        <h3 class="text-xl font-semibold mb-2">{{ new Date(session.date).toLocaleDateString() }}</h3>
        <p class="mb-2">Weapon: {{ session.weapon.name }}</p>
        <p class="mb-2">Duration: {{ session.duration }} minutes</p>
        <p class="mb-4">Location: {{ session.location }}</p>
        <div class="flex space-x-2">
          <button
            @click="editSession(session)"
            class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition-colors"
          >
            Edit
          </button>
          <button
            @click="deleteSession(session.id)"
            class="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
          >
            Delete
          </button>
        </div>
      </div>
    </div>

    <div v-if="showNewSessionForm" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <h2 class="text-2xl font-bold mb-4">{{ isEditing ? 'Edit' : 'New' }} Session</h2>
        <SessionForm
          :session="sessionToEdit"
          @submit="handleSubmit"
          @cancel="cancelForm"
        />
      </div>
    </div>

    <Notification
      :message="notificationMessage"
      :type="notificationType"
      @close="closeNotification"
    />
  </div>
</template>

<script>
import { ref, onMounted } from 'vue';
import SessionForm from '@/components/SessionForm.vue';
import Notification from '@/components/Notification.vue';
import { useSessions } from '@/composables/useSessions';

export default {
  components: { SessionForm, Notification },
  setup() {
    const { getSessions, createSession, updateSession, deleteSession } = useSessions();
    const sessions = ref([]);
    const loading = ref(true);
    const error = ref(null);
    const showNewSessionForm = ref(false);
    const isEditing = ref(false);
    const sessionToEdit = ref(null);
    const notificationMessage = ref('');
    const notificationType = ref('success');

    const fetchSessions = async () => {
      try {
        loading.value = true;
        sessions.value = await getSessions();
      } catch (err) {
        error.value = err.message;
      } finally {
        loading.value = false;
      }
    };

    onMounted(fetchSessions);

    const handleSubmit = async (formData) => {
      try {
        if (isEditing.value) {
          await updateSession(sessionToEdit.value.id, formData);
          notificationMessage.value = 'Session updated successfully';
        } else {
          await createSession(formData);
          notificationMessage.value = 'New session created successfully';
        }
        notificationType.value = 'success';
        await fetchSessions();
        showNewSessionForm.value = false;
      } catch (err) {
        notificationMessage.value = 'Error: ' + err.message;
        notificationType.value = 'error';
      }
    };

    const editSession = (session) => {
      sessionToEdit.value = session;
      isEditing.value = true;
      showNewSessionForm.value = true;
    };

    const deleteSession = async (id) => {
      if (confirm('Are you sure you want to delete this session?')) {
        try {
          await deleteSession(id);
          notificationMessage.value = 'Session deleted successfully';
          notificationType.value = 'success';
          await fetchSessions();
        } catch (err) {
          notificationMessage.value = 'Error deleting session: ' + err.message;
          notificationType.value = 'error';
        }
      }
    };

    const cancelForm = () => {
      showNewSessionForm.value = false;
      isEditing.value = false;
      sessionToEdit.value = null;
    };

    const closeNotification = () => {
      notificationMessage.value = '';
    };

    return {
      sessions,
      loading,
      error,
      showNewSessionForm,
      isEditing,
      sessionToEdit,
      notificationMessage,
      notificationType,
      handleSubmit,
      editSession,
      deleteSession,
      cancelForm,
      closeNotification
    };
  }
}
</script>