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

    // Basic validation
    if (!name || !address || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ message: 'Nimi, osoite ja sijainti (leveys- ja pituusaste) vaaditaan.' }); // Name, address, and location (lat/lng) are required.
    }

    const newRange = new ShootingRange({
      userId: req.user.id, // Link range to the authenticated user
      name,
      address,
      location: {
        type: 'Point',
        coordinates: [longitude, latitude], // GeoJSON stores [longitude, latitude]
      },
      notes,
      website,
      phoneNumber,
    });

    const savedRange = await newRange.save();
    res.status(201).json(savedRange); // Respond with the created range
  } catch (err) {
    console.error('Virhe ampumaradan luomisessa:', err.message); // Error creating shooting range
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(', ') });
    }
    res.status(500).json({ message: 'Palvelinvirhe ampumaradan luomisessa.' }); // Server error during range creation
  }
};

/**
 * @desc Get all shooting ranges for the authenticated user
 * @route GET /api/ranges
 * @access Private (requires authentication)
 */
exports.getRanges = async (req, res) => {
  try {
    // Find all ranges belonging to the authenticated user
    const ranges = await ShootingRange.find({ userId: req.user.id }).lean();
    res.json(ranges);
  } catch (err) {
    console.error('Virhe ampumaratojen hakemisessa:', err.message); // Error fetching shooting ranges
    res.status(500).json({ message: 'Palvelinvirhe ampumaratojen hakemisessa.' }); // Server error during range retrieval
  }
};

/**
 * @desc Get a single shooting range by ID
 * @route GET /api/ranges/:id
 * @access Private
 */
exports.getRangeById = async (req, res) => {
  try {
    const range = await ShootingRange.findOne({ _id: req.params.id, userId: req.user.id });
    if (!range) {
      return res.status(404).json({ message: 'Ampumarataa ei löytynyt tai se ei kuulu käyttäjälle.' }); // Shooting range not found or does not belong to user
    }
    res.json(range);
  } catch (err) {
    console.error('Virhe yksittäisen ampumaradan hakemisessa:', err.message); // Error fetching single shooting range
    if (err.name === 'CastError') {
      return res.status(400).json({ message: 'Virheellinen ampumaradan ID-muoto.' }); // Invalid range ID format
    }
    res.status(500).json({ message: 'Palvelinvirhe ampumaradan hakemisessa.' }); // Server error during range retrieval
  }
};