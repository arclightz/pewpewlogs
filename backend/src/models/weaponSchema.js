const config = require("../config/databaseConfig");
const { db } = require("../config/database");
let Weapon;

if (config.db.type === "mongodb") {
  const mongoose = require("mongoose");
  const weaponSchema = new mongoose.Schema({
    name: { type: String, required: true },
    type: { type: String, required: true },
    caliber: { type: String, required: true },
    toimintatapa: { type: String, required: true },
    erva: { type: Boolean, required: true },
  });

  Weapon = mongoose.model("Weapon", weaponSchema);
} else if (config.db.type === "mysql") {
  const createWeapon = (weaponData, callback) => {
    const query = "INSERT INTO Weapons SET ?";
    db.query(query, weaponData, callback);
  };

  const getWeaponById = (weaponId, callback) => {
    const query = "SELECT * FROM Weapons WHERE id = ?";
    db.query(query, [weaponId], (err, results) => {
      if (err) {
        return callback(err, null);
      }
      callback(null, results[0]);
    });
  };

  const getAllWeapons = (callback) => {
    const query = "SELECT * FROM Weapons";
    db.query(query, (err, results) => {
      if (err) {
        return callback(err, null);
      }
      callback(null, results);
    });
  };

  Weapon = {
    createWeapon,
    getWeaponById,
    getAllWeapons,
  };
}

module.exports = Weapon;
