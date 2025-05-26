// backend/src/controllers/sessionController.js
const Session = require('../models/sessions');
const Weapon = require('../models/weapons');
const ShootingRange = require('../models/shootingRanges');
const mongoose = require('mongoose');

/**
 * @desc Create a new shooting session
 * @route POST /api/sessions
 * @access Private (requires authentication)
 */
exports.createSession = async (req, res) => {
  try {
    const {
      date, range, weaponId, numberOfShotsFired, type, sportType, role, weather,
      ammunitionType, ammunitionCount, distanceToTarget, hits, misses, notes,
      result, hitFactor, compScore, photos, signature
    } = req.body;

    // Basic validation for new mandatory fields
    if (!date || !range || !weaponId || numberOfShotsFired === undefined || type === undefined || sportType === undefined) {
      return res.status(400).json({ message: 'Päivämäärä, ampumarata, ase, laukausten määrä, tyyppi ja laji vaaditaan istunnolle.' });
    }

    const weapon = await Weapon.findOne({ _id: weaponId, userId: req.user.id });
    if (!weapon) {
      return res.status(404).json({ message: 'Asetta ei löytynyt tai se ei kuulu käyttäjälle.' });
    }

    const shootingRange = await ShootingRange.findById(range);
    if (!shootingRange) {
      return res.status(404).json({ message: 'Ampumarataa ei löytynyt.' });
    }

    const newSession = new Session({
      userId: req.user.id,
      date,
      range,
      weapon: weaponId,
      numberOfShotsFired,
      type,
      sportType,
      role,
      weather,
      ammunitionType,
      ammunitionCount,
      distanceToTarget,
      hits,
      misses,
      notes,
      result,
      hitFactor,
      compScore,
      photos,
      signature
    });

    const savedSession = await newSession.save();

    // Populate weapon and range details for the response
    const populatedSession = await Session.findById(savedSession._id)
                                         .populate('weapon', 'name type caliber') // Added caliber
                                         .populate('range', 'name address')
                                         .lean(); // Use lean for faster response

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
      .populate('weapon', 'name type caliber') // Added caliber to populate
      .populate('range', 'name address')
      .sort({ date: -1 })
      .lean();

    res.json(sessions);
  } catch (err) {
    console.error('Virhe istuntojen hakemisessa:', err.message);
    res.status(500).json({ message: 'Palvelinvirhe istuntojen hakemisessa.' });
  }
};
