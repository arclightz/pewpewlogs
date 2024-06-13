var express = require('express');
var router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/userSchema')
const bcrypt = require('bcrypt');


// Register a new user
router.post('/register', async (req, res) => {
  try{
    const { username, email, password } = req.body;
    const newUser = new User({ username, email, password });
    await newUser.save();
    res.status(201).json({ message: 'User registeration successfully' });
  } catch (error) {
    console.error('Registration error:', error); // Log the full error
    res.status(500).json({ message: 'Registeration failed' });
  }  
});

// User login
router.post('/login', async (req, res) => {
  // Login logic here
  try {
    const { email, password } = req.body;
    console.log('Login attempt with email:', email); // Log email
    const user = await User.findOne({ email });
    if (!user) {
      console.log('User not found for email:', email); // Log if user is not found
      return res.status(401).json({ message: 'Authentication failed' });
    }
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      console.log('Password mismatch for email:', email); // Log if password doesn't match
      return res.status(401).json({ message: 'Authentication failed' });
    } 
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET);
    expiresIn: '1h'
    res.status(200).json({ token });
  } catch (error) {
    console.error('Login error:', error); // Log the full error
    res.status(500).json({ message: 'Login failed. Please try again' });
  }
});

module.exports = router;