const express = require("express");
const router = express.Router();
const Weapon = require("../models/weaponSchema");

/* GET weapons listing. */
router.get("/", async function (req, res, next) {
  try {
    const weapons = await Weapon.find({});
    res.json(weapons);
  } catch (err) {
    next(err);
  }
});

/* POST create a new weapon. */
router.post("/", async (req, res, next) => {
  console.log("Received POST request to /weapons with data:", req.body);
  try {
    console.log("Received POST request to /weapons with data:", req.body);
    // Extract attributes from request body
    const { name, type, caliber, toimintatapa, erva } = req.body;
    const newWeapon = new Weapon({
      name,
      type,
      caliber,
      toimintatapa,
      erva,
    });

    const savedWeapon = await newWeapon.save();
    res.status(201).send(`New weapon created with ID: ${savedWeapon._id}`);
  } catch (err) {
    console.error("Error saving weapon:", err); // Log the full error
    next(err);
  }
});

module.exports = router;
