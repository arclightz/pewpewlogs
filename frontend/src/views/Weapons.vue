<template>
  <div>
    <h1>Weapons</h1>
    <div>
      <h2>Existing Weapons</h2>
      <ul>
        <li v-for="weapon in weapons" :key="weapon.id">
          {{ weapon.name }}
        </li>
      </ul>
    </div>
    <div>
      <h2>Add New Weapon</h2>
      <form @submit.prevent="submitWeapon">
        <div>
          <label for="name">Weapon Name:</label>
          <input type="text" v-model="newWeapon.name" required />
        </div>
        <button type="submit">Add Weapon</button>
      </form>
    </div>
  </div>
</template>

<script>
import { getWeapons, addWeapon } from '../services/api';

export default {
  data() {
    return {
      weapons: [],
      newWeapon: {
        name: '',
      },
    };
  },
  created() {
    this.fetchWeapons();
  },
  methods: {
    fetchWeapons() {
      getWeapons()
        .then(response => {
          this.weapons = response.data;
        })
        .catch(error => {
          console.error('Error fetching weapons:', error);
        });
    },
    submitWeapon() {
      addWeapon(this.newWeapon)
        .then(response => {
          this.weapons.push(response.data);
          this.newWeapon.name = ''; // Clear the form
        })
        .catch(error => {
          console.error('Error adding weapon:', error);
        });
    },
  },
};
</script>

<style scoped>
/* Add your styles here */
</style>