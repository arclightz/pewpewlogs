const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const SessionSchema = new Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    default: Date.now,
    required: true
  },
  location: {
    type: String,
    required: true
  },
  shotsFired: {
    type: Number,
    required: true
  },
  notes: {
    type: String
  }
});

const Session = mongoose.model('Session', SessionSchema);

module.exports = Session;
