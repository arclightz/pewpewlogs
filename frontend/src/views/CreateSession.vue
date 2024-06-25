<template>
    <div>
      <h2 class="text-2xl font-bold mb-4">{{ isEditing ? 'Edit' : 'Create' }} Session</h2>
      <SessionForm
        :session="sessionToEdit"
        @submit="handleSubmit"
        @cancel="cancelForm"
      />
    </div>
  </template>
  
  <script>
  import { ref } from 'vue';
  import SessionForm from '@/components/SessionForm.vue';
  import { useSessions } from '@/composables/useSessions';
  
  export default {
    components: { SessionForm },
    setup() {
      const { createSession, updateSession } = useSessions();
      const isEditing = ref(false);
      const sessionToEdit = ref(null);
  
      const handleSubmit = async (formData) => {
        try {
          if (isEditing.value) {
            await updateSession(sessionToEdit.value.id, formData);
          } else {
            await createSession(formData);
          }
          // Handle success (e.g., show message, refresh list)
        } catch (error) {
          // Handle error
        }
      };
  
      const cancelForm = () => {
        // Reset form or close modal
      };
  
      return { isEditing, sessionToEdit, handleSubmit, cancelForm };
    }
  }
  </script>