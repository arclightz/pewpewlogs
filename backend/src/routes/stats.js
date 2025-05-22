// backend/src/routes/stats.js
const express = require('express');
const router = express.Router();
const statsController = require('../controllers/statsController'); // Import your stats controller
const authMiddleware = require('../middleware/auth'); // Import your JWT authentication middleware

/**
 * @route GET /api/stats
 * @desc Get aggregated statistics for the authenticated user
 * @access Private
 */
router.get('/', authMiddleware, statsController.getOverallStats);

module.exports = router;
