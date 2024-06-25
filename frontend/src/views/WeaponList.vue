<template>
  <div class="weapon-list">
    <h1>Your Weapons</h1>
    <button @click="showNewWeaponForm = true">Add New Weapon</button>
    <div v-if="loading">Loading weapons...</div>
    <div v-else-if="error">Error loading weapons: {{ error }}</div>
    <div v-else>
      <div v-for="weapon in weapons" :key="weapon.id" class="weapon-card">
        <h3>{{ weapon.name }}</h3>
        <div>Type: {{ weapon.type }}</div>
        <div>Caliber: {{ weapon.caliber }}</div>
        <button @click="editWeapon(weapon)">Edit</button>
        <button @click="deleteWeapon(weapon.id)">Delete</button>
      </div>
    </div>

    <div v-if="showNewWeaponForm" class="modal">
      <h2>New Weapon</h2>
      <form @submit.prevent="createWeapon">
        <!-- Form fields for new weapon -->
        <button type="submit">Add Weapon</button>
        <button @click="showNewWeaponForm = false">Cancel</button>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useWeapons } from '@/composables/useWeapons'

export default {
  setup() {
    const { getWeapons, createWeapon, updateWeapon, deleteWeapon } = useWeapons()
    const weapons = ref([])
    const loading = ref(true)
    const error = ref(null)
    const showNewWeaponForm = ref(false)

    onMounted(async () => {
      try {
        weapons.value = await getWeapons()
      } catch (e) {
        error.value = e.message
      } finally {
        loading.value = false
      }
    })

    const handleCreateWeapon = async (weaponData) => {
      try {
        await createWeapon(weaponData)
        weapons.value = await getWeapons()
        showNewWeaponForm.value = false
      } catch (e) {
        error.value = e.message
      }
    }

    const handleEditWeapon = async (weapon) => {
      // Implement edit functionality
    }

    const handleDeleteWeapon = async (weaponId) => {
      if (confirm('Are you sure you want to delete this weapon?')) {
        try {
          await deleteWeapon(weaponId)
          weapons.value = weapons.value.filter(w => w.id !== weaponId)
        } catch (e) {
          error.value = e.message
        }
      }
    }

    return {
      weapons,
      loading,
      error,
      showNewWeaponForm,
      createWeapon: handleCreateWeapon,
      editWeapon: handleEditWeapon,
      deleteWeapon: handleDeleteWeapon
    }
  }
}
</script>