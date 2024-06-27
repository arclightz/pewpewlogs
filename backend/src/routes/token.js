const express = require('express');
const router = express.Router();
const { kindeClient, authenticateUser } = require('../middleware/auth');

router.get('/', authenticateUser, async (req, res) => {
    console.log('Token route accessed');
  try {
    console.log('Getting token');
    const token = await kindeClient.getToken(req);
    res.json({ token });
  } catch (error) {
    console.error('Error getting token:', error);
    res.status(500).json({ error: 'Failed to retrieve token' });
  }
});

module.exports = router;