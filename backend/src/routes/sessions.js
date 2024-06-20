const express = require("express");
const router = express.Router();

// Create a new shooting session
router.post("/", function (req, res, next) {
  res.send("New shooting session created");
});

// Retrieve all sessions for the logged-in user
router.get("/", function (req, res, next) {
  res.send("All sessions retrieved");
});

// Retrieve a specific session by ID
router.get("/:id", function (req, res, next) {
  res.send(`Session ${req.params.id} retrieved`);
});

// Update a specific session by ID
router.put("/:id", function (req, res, next) {
  res.send(`Session ${req.params.id} updated`);
});

// Delete a specific session by ID
router.delete("/:id", function (req, res, next) {
  res.send(`Session ${req.params.id} deleted`);
});

module.exports = router;
