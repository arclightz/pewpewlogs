// backend/src/controllers/sessionController.js
const Session = require('../models/sessions'); // Import the Session model
const Weapon = require('../models/weapons'); // Import the Weapon model (to validate weaponId)

/**
 * @desc Create a new shooting session
 * @route POST /api/sessions
 * @access Private (requires authentication)
 */
exports.createSession = async (req, res) => {
  try {
    const { date, location, weaponId, ammunitionType, ammunitionCount, numberOfShotsFired, distanceToTarget, hits, misses, notes } = req.body;

    // Basic validation
    if (!date || !location || !weaponId) {
      return res.status(400).json({ message: 'Date, location, and weapon are required for a session.' });
    }

    // Verify if the weaponId belongs to the authenticated user
    const weapon = await Weapon.findOne({ _id: weaponId, userId: req.user.id });
    if (!weapon) {
      return res.status(404).json({ message: 'Weapon not found or does not belong to this user.' });
    }

    const newSession = new Session({
      userId: req.user.id, // Assign the session to the authenticated user
      date,
      location,
      weapon: weaponId, // Store the weapon's ObjectId
      ammunitionType,
      ammunitionCount,
      numberOfShotsFired,
      distanceToTarget,
      hits,
      misses,
      notes
    });

    const savedSession = await newSession.save();

    // Optionally, populate the weapon details for the response
    const populatedSession = await Session.findById(savedSession._id).populate('weapon', 'name type');

    res.status(201).json(populatedSession); // Respond with the created session
  } catch (err) {
    console.error('Error creating session:', err.message);
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(', ') });
    }
    res.status(500).json({ message: 'Server error during session creation.' });
  }
};

/**
 * @desc Get all shooting sessions for the authenticated user
 * @route GET /api/sessions
 * @access Private (requires authentication)
 */
exports.getSessions = async (req, res) => {
  try {
    // Find all sessions belonging to the authenticated user
    // Populate the 'weapon' field to get weapon details (name, type)
    const sessions = await Session.find({ userId: req.user.id })
      .populate('weapon', 'name type') // Select only name and type from the weapon
      .sort({ date: -1 }) // Sort by date in descending order (latest first)
      .lean(); // Use .lean() for faster query results if not needing Mongoose document methods

    res.json(sessions);
  } catch (err) {
    console.error('Error fetching sessions:', err.message);
    res.status(500).json({ message: 'Server error during session retrieval.' });
  }
};

// You can add more functions here for updating, deleting, or getting a single session by ID.
