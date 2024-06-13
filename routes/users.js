var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});

// Get user profile
router.get('/profile', function(req, res, next) {
  // Profile retrieval logic here

  const user = User.findById(req.userId);
  
  res.send('User profile data');
});

// Update user profile
router.put('/profile', function(req, res, next) {
  // Update profile logic here

  const { username, email } = req.body;
  const user = User.findByIdAndUpdate(req.userId, { username, email });
  
  res.send('User profile updated');
});

module.exports = router;
