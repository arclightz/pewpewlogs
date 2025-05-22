// backend/src/controllers/authController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/users'); // Assuming your user model is at this path

// Load environment variables (for JWT_SECRET)
require('dotenv').config();

// Secret key for JWT signing (use an environment variable in production)
const JWT_SECRET = process.env.JWT_SECRET || '5b8f0e3c7d9e4aefb1c0f46a7c13d29e8c45e14f9b11ab4e2c8f7d16bc9a3d5e'; // IMPORTANT: Use a strong, unique secret in your .env file!

/**
 * @desc Register a new user
 * @route POST /api/auth/register
 * @access Public
 */
exports.registerUser = async (req, res) => {
    const { name, email, password } = req.body;

    // Basic validation
    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Please enter all fields' });
    }

    try {
        // Check if user already exists
        let user = await User.findOne({ email });
        if (user) {
            return res.status(400).json({ message: 'User with that email already exists' });
        }

        // Create new user instance
        user = new User({
            name,
            email,
            password // This will be hashed before saving
        });

        // Hash password
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        // Save user to database
        await user.save();

        // Respond with success message (or token if you want to log them in immediately)
        res.status(201).json({ message: 'User registered successfully. Please log in.' });

    } catch (err) {
        console.error('Registration error:', err.message);
        res.status(500).json({ message: 'Server error during registration' });
    }
};

/**
 * @desc Authenticate user & get token
 * @route POST /api/auth/login
 * @access Public
 */
exports.loginUser = async (req, res) => {
    const { email, password } = req.body;

    // Basic validation
    if (!email || !password) {
        return res.status(400).json({ message: 'Please enter all fields' });
    }

    try {
        // Check for user
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Compare password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Generate JWT token
        const payload = {
            user: {
                id: user.id, // Mongoose virtual ID getter
                name: user.name,
                email: user.email
            },
        };

        jwt.sign(
            payload,
            JWT_SECRET,
            { expiresIn: '1h' }, // Token expires in 1 hour
            (err, token) => {
                if (err) throw err;
                res.json({
                    token,
                    user: {
                        id: user.id,
                        name: user.name,
                        email: user.email
                    },
                    message: 'Logged in successfully'
                });
            }
        );
    } catch (err) {
        console.error('Login error:', err.message);
        res.status(500).json({ message: 'Server error during login' });
    }
};

/**
 * @desc Get current authenticated user
 * @route GET /api/auth/me
 * @access Private
 * This function is accessed after the authMiddleware has verified the token
 * and attached the user payload (req.user) to the request object.
 */
exports.getMe = async (req, res) => {
    try {
        // req.user is populated by the auth middleware from the JWT payload.
        // Find the user by ID and select all fields EXCEPT the password hash.
        const user = await User.findById(req.user.id).select('-password');

        if (!user) {
            // This case should ideally not happen if authMiddleware works correctly,
            // but it's good for robustness.
            return res.status(404).json({ message: 'User not found' });
        }

        // Send back the user object (without the password)
        res.json({ user });
    } catch (err) {
        console.error('Get user error:', err.message);
        // If there's a server error during fetching, respond with 500
        res.status(500).json({ message: 'Server error' });
    }
};
