// backend/src/routes/auth.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController'); // Import your auth controller
const authMiddleware = require('../middleware/auth'); // Import your JWT authentication middleware

/**
 * @route POST /api/auth/register
 * @desc Register a new user
 * @access Public
 */
router.post('/register', authController.registerUser);

/**
 * @route POST /api/auth/login
 * @desc Authenticate user & get token
 * @access Public
 */
router.post('/login', authController.loginUser);

/**
 * @route GET /api/auth/me
 * @desc Get current authenticated user's profile
 * @access Private
 * This route uses the 'authMiddleware' to protect it, ensuring only
 * authenticated users can access their own profile data.
 */
router.get('/me', authMiddleware, authController.getMe);

module.exports = router;