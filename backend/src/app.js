// backend/src/app.js

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database'); // Import your database connection function
const authRoutes = require('./routes/auth'); // Import your new authentication routes
// const userRoutes = require('./routes/users'); // Import user-related routes
const sessionRoutes = require('./routes/sessions'); // Import session-related routes
const weaponRoutes = require('./routes/weapons'); // Import your new weapon routes
const statsRoutes = require('./routes/stats'); // Import stats-related routes
const shootingRangeRoutes = require('./routes/shootingRanges'); // Import shooting range-related routes

const app = express();

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
app.use('/api/ranges', shootingRangeRoutes);


// Basic route for testing if the API is running
app.get('/', (req, res) => res.send('API Running'));

// Global error handling middleware (optional, but highly recommended)
// This catches unhandled errors from your routes and sends a generic 500 response.
app.use((err, req, res, next) => {
    console.error('Unhandled server error:', err.stack); // Log the error stack for debugging
    res.status(500).send('Something broke on the server!');
});

module.exports = app; // Export the Express app instance for use in server.js
