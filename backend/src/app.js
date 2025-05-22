// backend/src/app.js

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database'); // Import your database connection function
const authRoutes = require('./routes/auth'); // Import your new authentication routes
// const userRoutes = require('./routes/users'); // Example: Import user-related routes
const sessionRoutes = require('./routes/sessions'); // Example: Import session-related routes
const weaponRoutes = require('./routes/weapons'); // <--- IMPORTANT: Import your new weapon routes
const statsRoutes = require('./routes/stats'); // Example: Import stats-related routes

const app = express();

// Connect to Database
// Note: The actual connection execution is typically done in the server.js file
// to ensure the application doesn't start listening until the DB is ready.
// This import is just making the function available.

// Init Middleware
// express.json() middleware parses incoming requests with JSON payloads.
// It's essential for handling data sent from your frontend forms (e.g., login, register).
app.use(express.json({ extended: false }));

// cors() middleware enables Cross-Origin Resource Sharing.
// This is necessary for your frontend (running on a different port/domain)
// to make requests to your backend. For production, you should configure
// CORS to allow requests only from your frontend's domain.
app.use(cors());

// Define Routes
// Mount your authentication routes under the /api/auth path.
app.use('/api/auth', authRoutes);
app.use('/api/weapons', weaponRoutes);
// app.use('/api/users', userRoutes);
app.use('/api/sessions', sessionRoutes); 
app.use('/api/weapons', weaponRoutes);
app.use('/api/stats', statsRoutes); 

// Mount your other application-specific routes.
// Ensure these files exist and export an Express Router.

// Basic route for testing if the API is running
app.get('/', (req, res) => res.send('API Running'));

// Global error handling middleware (optional, but highly recommended)
// This catches unhandled errors from your routes and sends a generic 500 response.
app.use((err, req, res, next) => {
    console.error('Unhandled server error:', err.stack); // Log the error stack for debugging
    res.status(500).send('Something broke on the server!');
});

module.exports = app; // Export the Express app instance for use in server.js
