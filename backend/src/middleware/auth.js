// backend/src/middleware/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config(); // Load environment variables

const JWT_SECRET = process.env.JWT_SECRET || '5b8f0e3c7d9e4aefb1c0f46a7c13d29e8c45e14f9b11ab4e2c8f7d16bc9a3d5e'; // IMPORTANT: Use the same secret

module.exports = function (req, res, next) {
    // Get token from header
    const token = req.header('x-auth-token');

    // Check if not token
    if (!token) {
        return res.status(401).json({ message: 'No token, authorization denied' });
    }

    // Verify token
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded.user; // Attach user payload to the request object
        next();
    } catch (err) {
        console.error('Token verification error:', err.message);
        res.status(401).json({ message: 'Token is not valid' });
    }
};