// backend/src/routes/shootingRanges.js
const express = require('express');
const router = express.Router();
const shootingRangeController = require('../controllers/shootingRangeController');
const authMiddleware = require('../middleware/auth');

/**
 * @route POST /api/ranges
 * @desc Create a new shooting range
 * @access Private
 */
router.post('/', authMiddleware, shootingRangeController.createRange);

/**
 * @route GET /api/ranges
 * @desc Get all shooting ranges for the authenticated user
 * @access Private
 */
router.get('/', authMiddleware, shootingRangeController.getRanges);

/**
 * @route GET /api/ranges/:id
 * @desc Get a single shooting range by ID
 * @access Private
 */
router.get('/:id', authMiddleware, shootingRangeController.getRangeById);

module.exports = router;
