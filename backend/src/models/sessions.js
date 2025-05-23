// backend/src/models/sessions.js
const mongoose = require('mongoose');

const SessionSchema = new mongoose.Schema({
  // Reference to the User who logged this session
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // Assumes your User model is named 'User'
    required: true
  },
  // Date and time of the shooting session
  date: {
    type: Date,
    required: [true, 'Istunnon päivämäärä vaaditaan'], // Session date is required
    default: Date.now
  },
  // NEW: Reference to the ShootingRange used in this session
  // Replaces the 'location' string field
  range: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ShootingRange', // Refers to the 'ShootingRange' model
    required: [true, 'Ampumarata vaaditaan istunnolle'] // Shooting range is required for the session
  },
  // Reference to the Weapon used in this session
  weapon: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Weapon', // Refers to the 'Weapon' model
    required: [true, 'Käytetty ase vaaditaan'] // Weapon used is required
  },
  // Ammunition details
  ammunitionType: {
    type: String,
    trim: true,
    maxlength: [50, 'Ammustyyppi voi olla enintään 50 merkkiä pitkä'] // Ammunition type cannot be more than 50 characters
  },
  ammunitionCount: {
    type: Number,
    min: [0, 'Ammusten määrä ei voi olla negatiivinen'], // Ammunition count cannot be negative
    default: 0
  },
  // Total number of shots fired in the session
  numberOfShotsFired: {
    type: Number,
    min: [0, 'Laukauksien määrä ei voi olla negatiivinen'], // Number of shots fired cannot be negative
    default: 0
  },
  // Distance from shooter to target (e.g., in meters or yards)
  distanceToTarget: {
    type: Number,
    min: [0, 'Etäisyys maaliin ei voi olla negatiivinen'], // Distance to target cannot be negative
    default: 0
  },
  // Basic hit/miss tracking
  hits: {
    type: Number,
    min: [0, 'Osumien määrä ei voi olla negatiivinen'], // Hits cannot be negative
    default: 0
  },
  misses: {
    type: Number,
    min: [0, 'Hutien määrä ei voi olla negatiivinen'], // Misses cannot be negative
    default: 0
  },
  // Additional notes for the session
  notes: {
    type: String,
    maxlength: [500, 'Muistiinpanot voivat olla enintään 500 merkkiä pitkiä'] // Notes cannot be more than 500 characters
  },
  // Trainer signature (for future expansion)
  trainerSignature: {
    type: String,
    default: null
  },
  // Photos (for future expansion)
  photos: [{
    type: String
  }]
}, {
  timestamps: true // Adds createdAt and updatedAt fields automatically
});

module.exports = mongoose.model('Session', SessionSchema);
