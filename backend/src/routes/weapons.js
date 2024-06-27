const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/auth');
const { Weapon } = require('../models');

// Get all weapons for the current user
router.get('/', authenticateUser, async (req, res) => {
  try {
    const weapons = await Weapon.findAll({ 
      where: { userId: req.user.id },
      order: [['createdAt', 'DESC']]
    });
    res.json(weapons);
  } catch (error) {
    console.error('Error retrieving weapons:', error);
    res.status(500).json({ message: 'Error retrieving weapons', error: error.message });
  }
});

// Create a new weapon for the current user
router.post('/', authenticateUser, async (req, res) => {
  try {
    const newWeapon = await Weapon.create({
      ...req.body,
      userId: req.user.id
    });
    res.status(201).json(newWeapon);
  } catch (error) {
    console.error('Error creating weapon:', error);
    res.status(400).json({ message: 'Error creating weapon', error: error.message });
  }
});

// Get specific weapon for the current user
router.get('/:id', authenticateUser, async (req, res) => {
  try {
    const weaponId = parseInt(req.params.id);
    if (isNaN(weaponId)) {
      return res.status(400).json({ message: 'Invalid weapon ID' });
    }

    const userId = req.user.id || req.user.sub; // Adjust based on your auth setup
    console.log(`User ${userId} requested weapon ${weaponId}`);

    const weapon = await Weapon.findOne({ 
      where: { 
        id: weaponId,
        userId: userId
      }
    });

    if (!weapon) {
      return res.status(404).json({ message: 'Weapon not found' });
    }

    res.json(weapon);
  } catch (error) {
    console.error('Error retrieving weapon:', error);
    res.status(500).json({ message: 'Error retrieving weapon', error: error.message });
  }
});
// Update a specific weapon
router.put('/:id', authenticateUser, async (req, res) => {
  try {
    const [updated] = await Weapon.update(req.body, {
      where: { 
        id: req.params.id,
        userId: req.user.id
      }
    });
    if (updated) {
      const updatedWeapon = await Weapon.findOne({ where: { id: req.params.id } });
      res.json(updatedWeapon);
    } else {
      res.status(404).json({ message: 'Weapon not found' });
    }
  } catch (error) {
    console.error('Error updating weapon:', error);
    res.status(400).json({ message: 'Error updating weapon', error: error.message });
  }
});

// Delete a specific weapon
router.delete('/:id', authenticateUser, async (req, res) => {
  try {
    const deleted = await Weapon.destroy({
      where: { 
        id: req.params.id,
        userId: req.user.id
      }
    });
    if (deleted) {
      res.status(204).send();
    } else {
      res.status(404).json({ message: 'Weapon not found' });
    }
  } catch (error) {
    console.error('Error deleting weapon:', error);
    res.status(500).json({ message: 'Error deleting weapon', error: error.message });
  }
});

module.exports = router;