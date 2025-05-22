// backend/src/models/users.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true // Ensures email addresses are unique
    },
    password: { // This will store the hashed password
        type: String,
        required: true
    },
    // You can add other profile fields here later, e.g.,
    // preferences: {
    //     type: Object,
    //     default: {}
    // },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('User', UserSchema);