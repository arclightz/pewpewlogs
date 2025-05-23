// backend/src/middleware/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || '5b8f0e3c7d9e4aefb1c0f46a7c13d29e8c45e14f9b11ab4e2c8f7d16bc9a3d5e';

module.exports = function (req, res, next) {
    // Get token from header
    const token = req.header('x-auth-token'); // This is the standard way

    console.log(`[Auth Middleware] Request URL: ${req.originalUrl}`);
    console.log(`[Auth Middleware] Received x-auth-token: ${token ? 'Present' : 'Absent'}`);
    if (token) {
        console.log(`[Auth Middleware] Token starts with: ${token.substring(0, 10)}...`);
    } else {
        console.log("[Auth Middleware] No token found in 'x-auth-token' header.");
    }

    // Check if not token
    if (!token) {
        console.warn("[Auth Middleware] Authorization denied: No token found.");
        return res.status(401).json({ message: 'No token, authorization denied' });
    }

    // Verify token
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded.user;
        console.log(`[Auth Middleware] Token verified. User ID: ${req.user.id}`);
        next();
    } catch (err) {
        console.error('Token verification error:', err.message);
        res.status(401).json({ message: 'Token is not valid' });
    }
};