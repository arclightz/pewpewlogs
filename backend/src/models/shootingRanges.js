// backend/src/models/shootingRanges.js
const mongoose = require('mongoose');

const ShootingRangeSchema = new mongoose.Schema({
  // Reference to the User who added this range
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // Assumes your User model is named 'User'
    required: true,
  },
  // Name of the shooting range (e.g., "Keski-Suomen Ampujat ry - Ampumarata")
  // This is the name that will be displayed to users
  name: {
    type: String,
    required: [true, 'Ampumaradan nimi vaaditaan'], // Range name is required
    trim: true,
    maxlength: [100, 'Nimi voi olla enintään 100 merkkiä pitkä'], // Name cannot be more than 100 characters
  },
  // Full address of the shooting range
  address: {
    type: String,
    required: [true, 'Osoite vaaditaan'], // Address is required
    trim: true,
    maxlength: [255, 'Osoite voi olla enintään 255 merkkiä pitkä'], // Address cannot be more than 255 characters
  },
  
  // Store location as a GeoJSON Point for geospatial queries
  // Coordinates are stored as [longitude, latitude] in GeoJSON
  location: {
    type: {
      type: String,
      enum: ['Point'], // 'location.type' must be 'Point'
      default: 'Point',
      required: true,
    },
    coordinates: {
      type: [Number], // Array of [longitude, latitude]
      required: [true, 'Koordinaatit vaaditaan'], // Coordinates are required
      index: '2dsphere' // Create a geospatial index for efficient location-based queries
    },
  },
  // Any additional notes about the range
  notes: {
    type: String,
    maxlength: [500, 'Muistiinpanot voivat olla enintään 500 merkkiä pitkiä'], // Notes cannot be more than 500 characters
    default: null,
  },
  // Website URL of the shooting range
  website: {
    type: String,
    trim: true,
    default: null,
  },
  // Phone number of the shooting range
  phoneNumber: {
    type: String,
    trim: true,
    default: null,
  },
}, {
  timestamps: true, // Automatically adds createdAt and updatedAt fields
});

module.exports = mongoose.model('ShootingRange', ShootingRangeSchema);
