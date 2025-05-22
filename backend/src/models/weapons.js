// backend/src/models/weapons.js
const mongoose = require('mongoose');

const WeaponSchema = new mongoose.Schema({
  // Name of the weapon (e.g., "Glock 19", "AR-15")
  name: {
    type: String,
    required: [true, 'Weapon name is required'],
    trim: true, // Remove whitespace from both ends of a string
    maxlength: [100, 'Name cannot be more than 100 characters']
  },
  // Type of weapon (e.g., "Pistol", "Rifle", "Shotgun")
  type: {
    type: String,
    required: [true, 'Weapon type is required'],
    trim: true,
    maxlength: [50, 'Type cannot be more than 50 characters']
  },
  // Caliber of the weapon (e.g., "9mm", ".223 Rem", "12 Gauge")
  caliber: {
    type: String,
    trim: true,
    maxlength: [50, 'Caliber cannot be more than 50 characters'],
    default: null // Allow null if not specified
  },
  // ERVA (Extremely dangerous weapon in finnish law) - assuming this is a boolean flag
  // Set to false by default if not provided
  erva: {
    type: Boolean,
    required: [true, 'ERVA status is required'],
    default: false
  },
  // Date when the weapon was purchased
  purchaseDate: {
    type: Date,
    default: null // Allow null if not specified
  },
  // Any additional notes about the weapon
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot be more than 500 characters'],
    default: null // Allow null if not specified
  },
  // Reference to the User who owns this weapon
  // This creates a relationship with the User model
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // Refers to the 'User' model (assuming your user model is named 'User')
    required: true
  },
  // Automatically add createdAt and updatedAt timestamps
}, {
  timestamps: true
});

module.exports = mongoose.model('Weapon', WeaponSchema);
