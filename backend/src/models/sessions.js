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
    required: [true, 'Session date is required'],
    default: Date.now // Default to current date/time if not provided
  },
  // Location where the session took place
  location: {
    type: String,
    required: [true, 'Location is required'],
    trim: true,
    maxlength: [100, 'Location cannot be more than 100 characters']
  },
  // Reference to the Weapon used in this session
  weapon: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Weapon', // Refers to the 'Weapon' model
    required: [true, 'Weapon used is required']
  },
  // Ammunition details (for MVP, maybe just type/count, can expand later)
  ammunitionType: {
    type: String,
    trim: true,
    maxlength: [50, 'Ammunition type cannot be more than 50 characters']
  },
  ammunitionCount: {
    type: Number,
    min: [0, 'Ammunition count cannot be negative'],
    default: 0
  },
  // Total number of shots fired in the session
  numberOfShotsFired: {
    type: Number,
    min: [0, 'Number of shots fired cannot be negative'],
    default: 0
  },
  // Distance from shooter to target (e.g., in meters or yards)
  distanceToTarget: {
    type: Number,
    min: [0, 'Distance to target cannot be negative'],
    default: 0
  },
  // Basic hit/miss tracking for MVP. Can be expanded to detailed shot placement later.
  hits: {
    type: Number,
    min: [0, 'Hits cannot be negative'],
    default: 0
  },
  misses: {
    type: Number,
    min: [0, 'Misses cannot be negative'],
    default: 0
  },
  // Additional notes for the session
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot be more than 500 characters']
  },
  // Trainer signature (for future expansion, can be a string for now or omitted)
  trainerSignature: {
    type: String,
    default: null
  },
  // Photos (for future expansion, can be an array of strings for image URLs)
  photos: [{
    type: String
  }]
}, {
  timestamps: true // Adds createdAt and updatedAt fields automatically
});

module.exports = mongoose.model('Session', SessionSchema);
