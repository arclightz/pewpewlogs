<template>
    <div>
      <h2 class="text-2xl font-bold mb-4">{{ isEditing ? 'Edit' : 'Create' }} Weapon</h2>
      <WeaponForm
        :weapon="weaponToEdit"
        @submit="handleSubmit"
        @cancel="cancelForm"
      />
    </div>
  </template>
  
  <script>
  import { ref } from 'vue';
  import WeaponForm from '@/components/WeaponForm.vue';
  import { useWeapons } from '@/composables/useWeapons';
  
  export default {
    components: { WeaponForm },
    setup() {
      const { createWeapon, updateWeapon } = useWeapons();
      const isEditing = ref(false);
      const weaponToEdit = ref(null);
  
      const handleSubmit = async (formData) => {
        try {
          if (isEditing.value) {
            await updateWeapon(weaponToEdit.value.id, formData);
          } else {
            await createWeapon(formData);
          }
          // Handle success (e.g., show message, refresh list)
        } catch (error) {
          // Handle error
        }
      };
  
      const cancelForm = () => {
        // Reset form or close modal
      };
  
      return { isEditing, weaponToEdit, handleSubmit, cancelForm };
    }
  }
  </script>