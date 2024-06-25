const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/auth');
const { User } = require('../models');

// Public route (if needed)
router.get('/public-info', (req, res) => {
  res.json({ message: "This is public user information" });
});

// Apply authentication middleware to all routes below this line
router.use(authenticateUser);

// Get current user's profile
router.get('/profile', async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving user profile', error: error.message });
  }
});

// Update current user's profile
router.put('/profile', async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const updatedUser = await user.update(req.body);
    res.json(updatedUser);
  } catch (error) {
    res.status(400).json({ message: 'Error updating user profile', error: error.message });
  }
});

// Get user's preferred weapon
router.get('/preferred-weapon', async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ preferredWeapon: user.preferredWeapon });
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving preferred weapon', error: error.message });
  }
});

// Update user's preferred weapon
router.put('/preferred-weapon', async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    user.preferredWeapon = req.body.preferredWeapon;
    await user.save();
    res.json({ message: 'Preferred weapon updated', preferredWeapon: user.preferredWeapon });
  } catch (error) {
    res.status(400).json({ message: 'Error updating preferred weapon', error: error.message });
  }
});

// Admin route: Get all users (requires admin role)
router.get('/all', async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied. Admin only.' });
    }
    const users = await User.findAll();
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving users', error: error.message });
  }
});

// Admin route: Delete a user (requires admin role)
router.delete('/:id', async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied. Admin only.' });
    }
    const user = await User.findByPk(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    await user.destroy();
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting user', error: error.message });
  }
});

module.exports = router;