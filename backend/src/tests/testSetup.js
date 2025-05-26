// backend/src/tests/testSetup.js

// IMPORTANT: Load environment variables from the correct path
require('dotenv').config({ path: './.env' }); 

const mongoose = require('mongoose');

// Define your test database URI.
// This should now correctly pull credentials from .env
const testDbUri = process.env.MONGODB_TEST_URI || 'mongodb://root:rootpassword@localhost:27017/pewpewlogs_test?authSource=admin';

beforeAll(async () => {
  console.log(`[Test Setup] Attempting to connect to test MongoDB: ${testDbUri}`);
  if (mongoose.connection.readyState === 0) {
    try {
      await mongoose.connect(testDbUri);
      console.log(`[Test Setup] Connected to test MongoDB: ${testDbUri}`);
    } catch (err) {
      console.error(`[Test Setup] Failed to connect to MongoDB for tests: ${err.message}`);
      process.exit(1); // Exit if connection fails
    }
  }
});

afterEach(async () => {
  // Clear the database after each test to ensure test isolation
  if (mongoose.connection.readyState === 1) { // Only attempt to clear if connected
    const collections = mongoose.connection.collections;
    for (const key in collections) {
      const collection = collections[key];
      // Ensure the collection has methods to delete before calling
      if (collection.deleteMany) {
        await collection.deleteMany({});
      } else {
        // Fallback for older Mongoose or specific collection types if needed
        console.warn(`[Test Setup] Collection ${key} does not have deleteMany method.`);
      }
    }
    console.log(`[Test Setup] Cleared collections in database.`);
  } else {
    console.warn('[Test Setup] Not connected to MongoDB, skipping collection clear.');
  }
});

afterAll(async () => {
  // Disconnect Mongoose after all tests are done
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
    console.log('[Test Setup] Disconnected from test MongoDB.');
  }
});
