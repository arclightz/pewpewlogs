// backend/src/controllers/shootingRangeController.js
const ShootingRange = require('../models/shootingRanges');
const mongoose = require('mongoose'); // Required for mongoose.Types.ObjectId

/**
 * @desc Create a new shooting range
 * @route POST /api/ranges
 * @access Private (requires authentication)
 */
exports.createRange = async (req, res) => {
  try {
    const { name, address, latitude, longitude, notes, website, phoneNumber } = req.body;

    if (!name || !address || latitude === undefined || longitude === undefined) {
      console.log("[ShootingRange Controller] Validation failed: Missing mandatory fields.");
      return res.status(400).json({ message: 'Nimi, osoite ja sijainti (leveys- ja pituusaste) vaaditaan.' });
    }

    const newRange = new ShootingRange({
      userId: req.user.id,
      name,
      address,
      location: {
        type: 'Point',
        coordinates: [longitude, latitude],
      },
      notes,
      website,
      phoneNumber,
    });

    const savedRange = await newRange.save();
    console.log("[ShootingRange Controller] Range created:", savedRange._id);
    res.status(201).json(savedRange);
  } catch (err) {
    console.error('Virhe ampumaradan luomisessa:', err.message);
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(', ') });
    }
    res.status(500).json({ message: 'Palvelinvirhe ampumaradan luomisessa.' });
  }
};

/**
 * @desc Get all shooting ranges (for any authenticated user)
 * @route GET /api/ranges
 * @access Private (requires authentication)
 */
exports.getRanges = async (req, res) => {
  try {
    const ranges = await ShootingRange.find({}).lean();
    console.log(`[ShootingRange Controller] getRanges: Found ${ranges.length} ranges.`);
    res.json(ranges);
  } catch (err) {
    console.error('Virhe ampumaratojen hakemisessa:', err.message);
    res.status(500).json({ message: 'Palvelinvirhe ampumaratojen hakemisessa.' });
  }
};

/**
 * @desc Get a single shooting range by ID (for any authenticated user)
 * @route GET /api/ranges/:id
 * @access Private
 */
exports.getRangeById = async (req, res) => {
  try {
    console.log(`[ShootingRange Controller] getRangeById: ID = ${req.params.id}`);
    const range = await ShootingRange.findById(req.params.id);
    if (!range) {
      console.log("[ShootingRange Controller] getRangeById: Range not found.");
      return res.status(404).json({ message: 'Ampumarataa ei löytynyt.' });
    }
    console.log("[ShootingRange Controller] getRangeById: Range found.");
    res.json(range);
  } catch (err) {
    console.error('Virhe yksittäisen ampumaradan hakemisessa:', err.message);
    if (err.name === 'CastError') {
      console.log("[ShootingRange Controller] getRangeById: Invalid ID format.");
      return res.status(400).json({ message: 'Virheellinen ampumaradan ID-muoto.' });
    }
    res.status(500).json({ message: 'Palvelinvirhe ampumaradan hakemisessa.' });
  }
};
