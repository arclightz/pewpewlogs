// backend/src/models/sessions.js
const mongoose = require('mongoose');

const SessionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: [true, 'Istunnon päivämäärä vaaditaan']
  },
  range: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ShootingRange',
    required: [true, 'Ampumarata vaaditaan istunnolle']
  },
  weapon: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Weapon',
    required: [true, 'Käytetty ase vaaditaan']
  },
  numberOfShotsFired: {
    type: Number,
    min: [0, 'Laukauksien määrä ei voi olla negatiivinen'],
    required: [true, 'Laukauksien määrä vaaditaan'], // Making this mandatory
    default: 0
  },

  // MANDATORY FIELDS
  type: { // session tyyppi (e.g., Kilpailu, Harjoitus)
    type: String,
    enum: ['Kilpailu', 'Harjoitus', 'Harjoituskilpailu', 'Kuivaharjoittelu', 'Seuran viikkokisa', 'Valmennus', 'Muu merkintä'],
    required: [true, 'Istunnon tyyppi vaaditaan']
  },
  sportType: { // Laji (e.g., Pienoiskivääriammunta, Skeet)
    type: String,
    required: [true, 'Laji vaaditaan']
  },
  weather: { // Sää (e.g., Aurinkoinen, Pilvinen, Sade) - optional, can be auto-filled
    type: String,
    default: null
  },
  role: { // Rooli harjoituksen aikana (e.g., Valmentaja, Rata-ammunnan johtaja) - optional
    type: String,
    enum: ['Ampuja', 'Valmentaja', 'Rata-ammunnan johtaja', 'Tuomari', 'Radanrakentaja', 'Muu rooli'],
    default: 'Ampuja' // Default role
  },

  // OPTIONAL FIELDS (expandable)
  result: { // Tulos (e.g., pistemäärä, aika)
    type: String, // Can be a number or string depending on sport
    default: null
  },
  hitFactor: { // Hit Factor (for IPSC/IDPA)
    type: Number,
    default: null
  },
  compScore: { // Competition Score (e.g., % of best score for IPSC)
    type: Number,
    default: null
  },
  distanceToTarget: { // Etäisyys maaliin - now optional
    type: Number,
    min: [0, 'Etäisyys maaliin ei voi olla negatiivinen'],
    default: null // Changed to null as it's optional
  },
  notes: { // Muistiinpanot
    type: String,
    maxlength: [1000, 'Muistiinpanot voivat olla enintään 1000 merkkiä pitkiä'], // Increased length
    default: null
  },
  // Placeholder for future image storage (URLs)
  photos: [{
    type: String,
    default: null
  }],
  // Placeholder for future signature image (URL)
  signature: {
    type: String,
    default: null
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Session', SessionSchema);
