<!-- src/views/UserProfile.vue -->
<template>
  <div class="user-profile">
    <h1>User Profile</h1>
    <div v-if="loading">Loading profile...</div>
    <div v-else-if="error">Error loading profile: {{ error }}</div>
    <div v-else>
      <form @submit.prevent="updateProfile">
        <div>
          <label for="firstName">First Name:</label>
          <input id="firstName" v-model="profile.firstName" type="text" required>
        </div>
        <div>
          <label for="lastName">Last Name:</label>
          <input id="lastName" v-model="profile.lastName" type="text" required>
        </div>
        <div>
          <label for="email">Email:</label>
          <input id="email" v-model="profile.email" type="email" required disabled>
        </div>
        <div>
          <label for="preferredWeapon">Preferred Weapon:</label>
          <select id="preferredWeapon" v-model="profile.preferredWeapon">
            <option v-for="weapon in weapons" :key="weapon.id" :value="weapon.id">
              {{ weapon.name }}
            </option>
          </select>
        </div>
        <button type="submit">Update Profile</button>
      </form>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useProfile } from '@/composables/useProfile'
import { useWeapons } from '@/composables/useWeapons'

export default {
  setup() {
    const { getProfile, updateProfile } = useProfile()
    const { getWeapons } = useWeapons()
    const profile = ref({})
    const weapons = ref([])
    const loading = ref(true)
    const error = ref(null)

    onMounted(async () => {
      try {
        [profile.value, weapons.value] = await Promise.all([
          getProfile(),
          getWeapons()
        ])
      } catch (e) {
        error.value = e.message
      } finally {
        loading.value = false
      }
    })

    const handleUpdateProfile = async () => {
      try {
        await updateProfile(profile.value)
        alert('Profile updated successfully')
      } catch (e) {
        error.value = e.message
      }
    }

    return { profile, weapons, loading, error, updateProfile: handleUpdateProfile }
  }
}
</script>