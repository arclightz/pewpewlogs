// backend/src/controllers/sessionController.js
const Session = require('../models/sessions');
const Weapon = require('../models/weapons');
const ShootingRange = require('../models/shootingRanges'); // Import ShootingRange model

/**
 * @desc Create a new shooting session
 * @route POST /api/sessions
 * @access Private (requires authentication)
 */
exports.createSession = async (req, res) => {
  try {
    const { date, range, weaponId, ammunitionType, ammunitionCount, numberOfShotsFired, distanceToTarget, hits, misses, notes } = req.body;

    if (!date || !range || !weaponId) {
      return res.status(400).json({ message: 'Päivämäärä, ampumarata ja ase vaaditaan istunnolle.' });
    }

    // Verify if the weaponId belongs to the authenticated user (STILL REQUIRED)
    const weapon = await Weapon.findOne({ _id: weaponId, userId: req.user.id });
    if (!weapon) {
      return res.status(404).json({ message: 'Asetta ei löytynyt tai se ei kuulu käyttäjälle.' });
    }

    // FIX: Only verify that the range EXISTS, not that it belongs to the user
    const shootingRange = await ShootingRange.findById(range); // Removed userId filter
    if (!shootingRange) {
      return res.status(404).json({ message: 'Ampumarataa ei löytynyt.' }); // Shooting range not found
    }

    const newSession = new Session({
      userId: req.user.id,
      date,
      range,
      weapon: weaponId,
      ammunitionType,
      ammunitionCount,
      numberOfShotsFired,
      distanceToTarget,
      hits,
      misses,
      notes
    });

    const savedSession = await newSession.save();

    const populatedSession = await Session.findById(savedSession._id)
                                         .populate('weapon', 'name type')
                                         .populate('range', 'name address');

    res.status(201).json(populatedSession);
  } catch (err) {
    console.error('Virhe istunnon luomisessa:', err.message);
    if (err.name === 'ValidationError') {
      const messages = Object.values(err.errors).map(val => val.message);
      return res.status(400).json({ message: messages.join(', ') });
    }
    res.status(500).json({ message: 'Palvelinvirhe istunnon luomisessa.' });
  }
};

/**
 * @desc Get all shooting sessions for the authenticated user
 * @route GET /api/sessions
 * @access Private (requires authentication)
 */
exports.getSessions = async (req, res) => {
  try {
    const sessions = await Session.find({ userId: req.user.id })
      .populate('weapon', 'name type')
      .populate('range', 'name address')
      .sort({ date: -1 })
      .lean();

    res.json(sessions);
  } catch (err) {
    console.error('Virhe istuntojen hakemisessa:', err.message);
    res.status(500).json({ message: 'Palvelinvirhe istuntojen hakemisessa.' });
  }
};
