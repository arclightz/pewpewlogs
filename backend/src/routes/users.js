const express = require("express");
const kindeClient = require("../middleware/kindeClient");
const verifyToken = require("../middleware/authMiddleware");
const router = express.Router();

router.get("/profile", verifyToken, (req, res) => {
  res.render("profile", {
    title: "Profile",
    user: req.user,
  });
});

module.exports = router;