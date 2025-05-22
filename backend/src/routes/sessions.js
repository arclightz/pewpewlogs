// backend/src/routes/sessions.js
const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController'); // Import your session controller
const authMiddleware = require('../middleware/auth'); // Import your JWT authentication middleware

/**
 * @route POST /api/sessions
 * @desc Create a new shooting session
 * @access Private
 * This route requires authentication to ensure a session is associated with a user.
 */
router.post('/', authMiddleware, sessionController.createSession);

/**
 * @route GET /api/sessions
 * @desc Get all shooting sessions for the authenticated user
 * @access Private
 * This route requires authentication to fetch only the user's own sessions.
 */
router.get('/', authMiddleware, sessionController.getSessions);

module.exports = router;
