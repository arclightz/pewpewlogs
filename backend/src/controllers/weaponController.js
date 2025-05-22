// backend/src/controllers/weaponController.js
const Weapon = require('../models/weapons'); // Import the Weapon model

/**
 * @desc Create a new weapon
 * @route POST /api/weapons
 * @access Private (requires authentication)
 */
exports.createWeapon = async (req, res) => {
  try {
    // req.user.id comes from the JWT authentication middleware
    const { name, type, caliber, erva, purchaseDate, notes } = req.body;

    // Basic validation
    if (!name || !type) {
      return res.status(400).json({ message: 'Name and type are required for a weapon.' });
    }

    const newWeapon = new Weapon({
      name,
      type,
      caliber,
      erva: erva || false, // Ensure erva defaults to false if not provided
      purchaseDate: purchaseDate || null,
      notes: notes || null,
      userId: req.user.id // Assign the weapon to the authenticated user
    });

    const savedWeapon = await newWeapon.save();
    res.status(201).json(savedWeapon); // Respond with the created weapon
  } catch (err) {
    console.error('Error creating weapon:', err.message);
    // Handle Mongoose validation errors specifically
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(', ') });
    }
    res.status(500).json({ message: 'Server error during weapon creation.' });
  }
};

/**
 * @desc Get all weapons for the authenticated user
 * @route GET /api/weapons
 * @access Private (requires authentication)
 */
exports.getWeapons = async (req, res) => {
  try {
    // Find all weapons belonging to the authenticated user
    // We use .lean() for faster query results if we don't need Mongoose document methods
    const weapons = await Weapon.find({ userId: req.user.id }).lean();
    res.json(weapons);
  } catch (err) {
    console.error('Error fetching weapons:', err.message);
    res.status(500).json({ message: 'Server error during weapon retrieval.' });
  }
};

// You can add more functions here for updating, deleting, or getting a single weapon by ID.
