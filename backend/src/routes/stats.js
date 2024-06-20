const express = require("express");
const router = express.Router();

// Retrieve statistics for sessions
router.get("/sessions", function (req, res, next) {
  res.send("Session statistics retrieved");
});

// Retrieve shooting statistics
router.get("/shots", function (req, res, next) {
  res.send("Shooting statistics retrieved");
});

module.exports = router;
