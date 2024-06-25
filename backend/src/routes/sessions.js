const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/auth');
const { Session, User, Weapon } = require('../models');

router.use(authenticateUser);

// Get all sessions for the current user
router.get('/', async (req, res) => {
  try {
    const sessions = await Session.findAll({
      where: { userId: req.user.id },
      include: [{ model: Weapon, attributes: ['id', 'name'] }]
    });
    res.json(sessions);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving sessions', error: error.message });
  }
});

// Get a specific session
router.get('/:id', async (req, res) => {
  try {
    const session = await Session.findOne({
      where: { id: req.params.id, userId: req.user.id },
      include: [{ model: Weapon, attributes: ['id', 'name'] }]
    });
    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }
    res.json(session);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving session', error: error.message });
  }
});

// Create a new session
router.post('/', async (req, res) => {
  try {
    const newSession = await Session.create({
      ...req.body,
      userId: req.user.id
    });
    res.status(201).json(newSession);
  } catch (error) {
    res.status(400).json({ message: 'Error creating session', error: error.message });
  }
});

// Update a session
router.put('/:id', async (req, res) => {
  try {
    const session = await Session.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });
    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }
    const updatedSession = await session.update(req.body);
    res.json(updatedSession);
  } catch (error) {
    res.status(400).json({ message: 'Error updating session', error: error.message });
  }
});

// Delete a session
router.delete('/:id', async (req, res) => {
  try {
    const session = await Session.findOne({
      where: { id: req.params.id, userId: req.user.id }
    });
    if (!session) {
      return res.status(404).json({ message: 'Session not found' });
    }
    await session.destroy();
    res.json({ message: 'Session deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting session', error: error.message });
  }
});

module.exports = router;