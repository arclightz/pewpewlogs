// This file is responsible for connecting to the MongoDB database.
// backend/src/config/database.js
const mongoose = require('mongoose');

// Replace with your MongoDB connection string.
// For local MongoDB: 'mongodb://localhost:27017/pewpewlogs'
// For MongoDB Atlas: 'mongodb+srv://<username>:<password>@<cluster-name>.mongodb.net/pewpewlogs?retryWrites=true&w=majority'
const dbURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/pewpewlogs';

const connectDB = async () => {
    try {
        await mongoose.connect(dbURI, {
            // useNewUrlParser: true, // Deprecated in Mongoose 6+
            // useUnifiedTopology: true, // Deprecated in Mongoose 6+
            // useCreateIndex: true, // Deprecated in Mongoose 6+
            // useFindAndModify: false // Deprecated in Mongoose 6+
        });
        console.log('MongoDB Connected...');
    } catch (err) {
        console.error(err.message);
        // Exit process with failure
        process.exit(1);
    }
};

module.exports = connectDB;