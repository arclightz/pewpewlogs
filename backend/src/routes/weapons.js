const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/auth');
const { Weapon } = require('../models');

router.use(authenticateUser);

// Get all weapons for the current user
router.get('/', async (req, res) => {
  try {
    const weapons = await Weapon.findAll({ where: { userId: req.user.id } });
    res.json(weapons);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving weapons', error: error.message });
  }
});

// Get a specific weapon
router.get('/:id', async (req, res) => {
  try {
    const weapon = await Weapon.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });
    if (!weapon) {
      return res.status(404).json({ message: 'Weapon not found' });
    }
    res.json(weapon);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving weapon', error: error.message });
  }
});

// Create a new weapon
router.post('/', async (req, res) => {
  try {
    const newWeapon = await Weapon.create({
      ...req.body,
      userId: req.user.id
    });
    res.status(201).json(newWeapon);
  } catch (error) {
    res.status(400).json({ message: 'Error creating weapon', error: error.message });
  }
});

// Update a weapon
router.put('/:id', async (req, res) => {
  try {
    const weapon = await Weapon.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });
    if (!weapon) {
      return res.status(404).json({ message: 'Weapon not found' });
    }
    const updatedWeapon = await weapon.update(req.body);
    res.json(updatedWeapon);
  } catch (error) {
    res.status(400).json({ message: 'Error updating weapon', error: error.message });
  }
});

// Delete a weapon
router.delete('/:id', async (req, res) => {
  try {
    const weapon = await Weapon.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });
    if (!weapon) {
      return res.status(404).json({ message: 'Weapon not found' });
    }
    await weapon.destroy();
    res.json({ message: 'Weapon deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting weapon', error: error.message });
  }
});

module.exports = router;