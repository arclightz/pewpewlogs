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
      return res.status(400).json({ message: 'Nimi, osoite ja sijainti (leveys- ja pituusaste) vaaditaan.' });
    }

    const newRange = new ShootingRange({
      userId: req.user.id, // Still link to the user who created it
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
    // FIX: Removed userId filter. All authenticated users can see all ranges.
    const ranges = await ShootingRange.find({}).lean(); // No filter by userId
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
    // FIX: Removed userId filter. Any authenticated user can get a range by ID.
    const range = await ShootingRange.findById(req.params.id);
    if (!range) {
      return res.status(404).json({ message: 'Ampumarataa ei löytynyt.' }); // Range not found
    }
    res.json(range);
  } catch (err) {
    console.error('Virhe yksittäisen ampumaradan hakemisessa:', err.message);
    if (err.name === 'CastError') {
      return res.status(400).json({ message: 'Virheellinen ampumaradan ID-muoto.' });
    }
    res.status(500).json({ message: 'Palvelinvirhe ampumaradan hakemisessa.' });
  }
};
