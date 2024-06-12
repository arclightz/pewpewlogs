const mongoose = require('mongoose');

// Define a simple Weapon schema
const weaponSchema = new mongoose.Schema({
    name: { type: String, required: true },
    type: { type: String, required: true },
    caliber: { type: String, required: true} ,
    toimintatapa: { type: String, required: true }, 
    erva: { type: Boolean, required: true }
});

// Create a model based on the schema
const Weapon = mongoose.model('Weapon', weaponSchema);

module.exports = Weapon;