// backend/src/tests/weapons.test.js
const request = require('supertest');
const app = require('../app');
const User = require('../models/users');
const Weapon = require('../models/weapons');

// Load environment variables for tests
require('dotenv').config({ path: './.env' });
const TEST_USER_PASSWORD = process.env.TEST_USER_PASSWORD || 'testpassword123';

describe('Weapon API', () => {
  let authToken; // To store the token for authenticated requests
  let testUser;  // To store the created test user

  // Before all tests, create a user and log them in to get an auth token
  beforeAll(async () => {
    // Register a user
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Weapon Test User',
        email: 'weapon.test@example.com',
        password: TEST_USER_PASSWORD,
      });

    // Log in the user to get a token
    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'weapon.test@example.com',
        password: TEST_USER_PASSWORD,
      });
    authToken = loginRes.body.token;
    testUser = await User.findOne({ email: 'weapon.test@example.com' });
  });

  // Test creating a weapon
  it('should create a new weapon successfully for an authenticated user', async () => {
    const res = await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken) // Set auth token
      .send({
        name: 'Testipistooli',
        type: 'Pistooli', // Must match enum in backend/src/models/weapons.js
        caliber: '9mm',
        erva: false,
        purchaseDate: '2023-01-01',
        notes: 'Ensimmäinen testipistooli.',
      });

    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('_id');
    expect(res.body.name).toEqual('Testipistooli');
    expect(res.body.userId.toString()).toEqual(testUser._id.toString()); // Check ownership

    const weaponInDb = await Weapon.findById(res.body._id);
    expect(weaponInDb).not.toBeNull();
    expect(weaponInDb.name).toEqual('Testipistooli');
  });

  it('should not create a weapon without required fields', async () => {
    const res = await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken)
      .send({
        name: 'Puuttuva tyyppi',
        // type is missing
        caliber: '.22LR',
      });
    expect(res.statusCode).toEqual(400);
    expect(res.body.message).toContain('Name and type are required for a weapon.'); // Or specific message from your validation
  });

  it('should not create a weapon with an invalid type enum', async () => {
    const res = await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken)
      .send({
        name: 'Väärä tyyppi',
        type: 'Väärä Tyyppi', // Invalid type
        caliber: '9mm',
      });
    expect(res.statusCode).toEqual(400);
    expect(res.body.message).toContain('is not a valid enum value');
  });

  it('should not create a weapon if not authenticated', async () => {
    const res = await request(app)
      .post('/api/weapons')
      .send({ // No auth token
        name: 'Unauthenticated Weapon',
        type: 'Pistooli',
        caliber: '9mm',
      });
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });

  // Test getting weapons
  it('should get all weapons for the authenticated user', async () => {
    // Add the first weapon for the user
    await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken)
      .send({
        name: 'Testipistooli',
        type: 'Pistooli',
        caliber: '9mm',
        erva: false,
        purchaseDate: '2023-01-01',
        notes: 'Ensimmäinen testipistooli.',
      });

    // Add a second weapon for the user
    await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken)
      .send({
        name: 'Testikivääri',
        type: 'Kivääri',
        caliber: '7.62x39mm',
        erva: false,
      });

    const res = await request(app)
      .get('/api/weapons')
      .set('x-auth-token', authToken);

    expect(res.statusCode).toEqual(200);
    expect(res.body.length).toBeGreaterThanOrEqual(2); // At least the two we added
    expect(res.body.some(w => w.name === 'Testipistooli')).toBe(true);
    expect(res.body.some(w => w.name === 'Testikivääri')).toBe(true);
  });

  it('should not get weapons if not authenticated', async () => {
    const res = await request(app)
      .get('/api/weapons');
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });
});
