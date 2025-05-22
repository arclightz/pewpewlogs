// backend/src/routes/weapons.js
const express = require('express');
const router = express.Router();
const weaponController = require('../controllers/weaponController'); // Import your weapon controller
const authMiddleware = require('../middleware/auth'); // Import your JWT authentication middleware

/**
 * @route POST /api/weapons
 * @desc Create a new weapon
 * @access Private
 * This route requires authentication to ensure a weapon is associated with a user.
 */
router.post('/', authMiddleware, weaponController.createWeapon);

/**
 * @route GET /api/weapons
 * @desc Get all weapons for the authenticated user
 * @access Private
 * This route requires authentication to fetch only the user's own weapons.
 */
router.get('/', authMiddleware, weaponController.getWeapons);

module.exports = router;
