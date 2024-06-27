<template>
  <div class="weapon-list p-4 bg-gray-100 min-h-screen">
    <h1 class="text-2xl font-bold mb-4 text-gray-800">Your Weapons</h1>
    <button @click="showNewWeaponForm = true" class="bg-blue-500 text-white px-4 py-2 rounded mb-4 hover:bg-blue-600">Add New Weapon</button>
    <div v-if="loading" class="text-gray-600">Loading weapons...</div>
    <div v-else-if="error" class="text-red-500">Error loading weapons: {{ error }}</div>
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div v-for="weapon in weapons" :key="weapon.id" class="bg-white p-4 rounded shadow">
        <h3 class="text-lg font-semibold text-gray-800">{{ weapon.name }}</h3>
        <div class="text-gray-600">Type: {{ weapon.type }}</div>
        <div class="text-gray-600">Caliber: {{ weapon.caliber }}</div>
        <div class="mt-2">
          <button @click="handleEditWeapon(weapon)" class="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600">Edit</button>
          <button @click="handleDeleteWeapon(weapon.id)" class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">Delete</button>
        </div>
      </div>
    </div>
    <div v-if="showNewWeaponForm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div class="bg-white p-6 rounded-lg w-full max-w-md">
        <h2 class="text-xl font-bold mb-4 text-gray-800">{{ editingWeapon ? 'Edit' : 'New' }} Weapon</h2>
        <WeaponForm 
          :weapon="editingWeapon"
          @submit="editingWeapon ? handleUpdateWeapon : handleCreateWeapon"
          @cancel="closeForm"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useWeapons } from '../composables/useWeapons';
import WeaponForm from '../components/WeaponForm.vue';
import { getUser } from '../services/kinde'; // Ensure user is authenticated

const { getWeapons, createWeapon, updateWeapon, deleteWeapon } = useWeapons();
const weapons = ref([]);
const loading = ref(true);
const error = ref(null);
const showNewWeaponForm = ref(false);
const editingWeapon = ref(null);

onMounted(async () => {
  try {
    const user = await getUser();
    if (!user) {
      throw new Error('User not authenticated');
    }
    weapons.value = await getWeapons();
  } catch (e) {
    error.value = e.message;
  } finally {
    loading.value = false;
  }
});

const handleCreateWeapon = async (weaponData) => {
  try {
    await createWeapon(weaponData);
    weapons.value = await getWeapons();
    showNewWeaponForm.value = false;
  } catch (e) {
    error.value = e.message;
  }
};

const handleEditWeapon = (weapon) => {
  editingWeapon.value = weapon;
  showNewWeaponForm.value = true;
};

const handleUpdateWeapon = async (weaponData) => {
  try {
    await updateWeapon(editingWeapon.value.id, weaponData);
    weapons.value = await getWeapons();
    showNewWeaponForm.value = false;
    editingWeapon.value = null;
  } catch (e) {
    error.value = e.message;
  }
};

const handleDeleteWeapon = async (weaponId) => {
  if (confirm('Are you sure you want to delete this weapon?')) {
    try {
      await deleteWeapon(weaponId);
      weapons.value = weapons.value.filter(w => w.id !== weaponId);
    } catch (e) {
      error.value = e.message;
    }
  }
};

const closeForm = () => {
  showNewWeaponForm.value = false;
  editingWeapon.value = null;
};
</script>

<style scoped>
/* Add any styles you need for the WeaponList component */
</style>
