// backend/src/models/users.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  // Ensure virtuals (like 'id' from '_id') are included when converting to JSON
  toJSON: {
    virtuals: true,
    transform: (doc, ret) => {
      delete ret._id; // Optionally remove _id if you only want 'id'
      delete ret.password; // Ensure password is never sent
      return ret;
    }
  },
  // Ensure virtuals are created
  id: false // Disable default id virtual to define our own if needed, or rely on default
});

// If you explicitly want to define the virtual 'id'
UserSchema.virtual('id').get(function() {
  return this._id.toHexString();
});

module.exports = mongoose.model('User', UserSchema);
