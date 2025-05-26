// backend/src/models/weapons.js
const mongoose = require('mongoose');

const WeaponSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Aseen nimi vaaditaan'], 
    trim: true,
    maxlength: [100, 'Nimi voi olla enintään 100 merkkiä pitkä'] 
  },
  
  type: {
    type: String,
    required: [true, 'Aseen tyyppi vaaditaan'], 
    trim: true,
    maxlength: [50, 'Tyyppi voi olla enintään 50 merkkiä pitkä'], 
    enum: ['Pistooli', 'Kivääri', 'Haulikko', 'Revolveri', 'PCC', 'Ilma-ase', 'Deaktivoitu ampuma-ase','Muu','Yhdistelmäase', 'Merkinantoase', 'Kaasuase'],
  },
  caliber: {
    type: String,
    trim: true,
    maxlength: [50, 'Kaliiberi voi olla enintään 50 merkkiä pitkä'], 
    default: null
  },
  erva: {
    type: Boolean,
    required: [true, 'ERVA-status vaaditaan'], 
    default: false
  },
  purchaseDate: {
    type: Date,
    default: null
  },
  notes: {
    type: String,
    maxlength: [500, 'Muistiinpanot voivat olla enintään 500 merkkiä pitkiä'], 
    default: null
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
}, {
  timestamps: true
});

module.exports = mongoose.model('Weapon', WeaponSchema);
