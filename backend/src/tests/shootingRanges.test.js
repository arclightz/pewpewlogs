// backend/src/tests/shootingRanges.test.js
const request = require('supertest');
const app = require('../app');
const User = require('../models/users');
const ShootingRange = require('../models/shootingRanges');
const mongoose = require('mongoose');

// Load environment variables for tests
require('dotenv').config({ path: './.env' });
const TEST_USER_PASSWORD = process.env.TEST_USER_PASSWORD || 'testpassword123';

describe('Shooting Range API', () => {
  let authToken;
  let testUser;
  let anotherUserAuthToken; // For testing public access but different creator

  beforeAll(async () => {
    // Create main test user and get token
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Range Test User',
        email: 'range.test@example.com',
        password: TEST_USER_PASSWORD,
      });
    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'range.test@example.com',
        password: TEST_USER_PASSWORD,
      });
    authToken = loginRes.body.token;
    testUser = await User.findOne({ email: 'range.test@example.com' });

    // Create another user for ownership tests
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Another Range User',
        email: 'another.range@example.com',
        password: TEST_USER_PASSWORD,
      });
    const anotherLoginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'another.range@example.com',
        password: TEST_USER_PASSWORD,
      });
    anotherUserAuthToken = anotherLoginRes.body.token;
  });

  // Test creating a shooting range
  it('should create a new shooting range successfully for an authenticated user', async () => {
    const res = await request(app)
      .post('/api/ranges')
      .set('x-auth-token', authToken)
      .send({
        name: 'Testirata 1',
        address: 'Testikatu 1, 00100 Helsinki',
        latitude: 60.1695,
        longitude: 24.9354,
        notes: 'Sisärata',
        website: 'http://testirata1.fi',
        phoneNumber: '0101234567',
      });

    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('_id');
    expect(res.body.name).toEqual('Testirata 1');
    expect(res.body.userId.toString()).toEqual(testUser._id.toString());

    const rangeInDb = await ShootingRange.findById(res.body._id);
    expect(rangeInDb).not.toBeNull();
    expect(rangeInDb.address).toEqual('Testikatu 1, 00100 Helsinki');
  });

  it('should not create a shooting range without required fields', async () => {
    const res = await request(app)
      .post('/api/ranges')
      .set('x-auth-token', authToken)
      .send({
        name: 'Puuttuva osoite',
        // address is missing
        latitude: 60.1695,
        longitude: 24.9354,
      });
    expect(res.statusCode).toEqual(400);
    expect(res.body.message).toContain('Nimi, osoite ja sijainti (leveys- ja pituusaste) vaaditaan.'); // Specific message from your validation
  });

  it('should not create a shooting range if not authenticated', async () => {
    const res = await request(app)
      .post('/api/ranges')
      .send({ // No auth token
        name: 'Unauthenticated Range',
        address: 'No street 1',
        latitude: 60,
        longitude: 20,
      });
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });

  // Test getting all shooting ranges (should be public to auth users)
  it('should get all shooting ranges for any authenticated user', async () => {
    // Ensure a clean state
    await ShootingRange.deleteMany({});

    // Create a range by the main test user
    await request(app)
      .post('/api/ranges')
      .set('x-auth-token', authToken)
      .send({
        name: 'Testirata 1',
        address: 'Testikatu 1, 00100 Helsinki',
        latitude: 60.1695,
        longitude: 24.9354,
        notes: 'Sisärata',
        website: 'http://testirata1.fi',
        phoneNumber: '0101234567',
      });

    // Create a range by another user
    await request(app)
      .post('/api/ranges')
      .set('x-auth-token', anotherUserAuthToken)
      .send({
        name: 'Testirata 2 (Other User)',
        address: 'Toinen katu 2, 00200 Helsinki',
        latitude: 60.1,
        longitude: 24.5,
      });

    const res = await request(app)
      .get('/api/ranges')
      .set('x-auth-token', authToken); // Use main test user's token

    expect(res.statusCode).toEqual(200);
    expect(res.body.length).toBeGreaterThanOrEqual(2); // At least the one we created + the other user's
    expect(res.body.some(r => r.name === 'Testirata 1')).toBe(true);
    expect(res.body.some(r => r.name === 'Testirata 2 (Other User)')).toBe(true);
  });

  it('should not get shooting ranges if not authenticated', async () => {
    const res = await request(app)
      .get('/api/ranges'); // No token
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });

  // Test getting a single shooting range by ID
  it('should get a single shooting range by ID for any authenticated user', async () => {
    const newRange = await ShootingRange.create({
      userId: testUser._id,
      name: 'Haettava Rata',
      address: 'Haettava Katu 3',
      location: { type: 'Point', coordinates: [26, 61] },
    });

    const res = await request(app)
      .get(`/api/ranges/${newRange._id}`)
      .set('x-auth-token', anotherUserAuthToken); // Another user should be able to get it

    expect(res.statusCode).toEqual(200);
    expect(res.body.name).toEqual('Haettava Rata');
    expect(res.body._id.toString()).toEqual(newRange._id.toString());
  });

  it('should return 404 if shooting range not found', async () => {
    const nonExistentId = new mongoose.Types.ObjectId(); // Create a valid but non-existent ID
    const res = await request(app)
      .get(`/api/ranges/${nonExistentId}`)
      .set('x-auth-token', authToken);
    expect(res.statusCode).toEqual(404);
    expect(res.body.message).toEqual('Ampumarataa ei löytynyt.');
  });

  it('should return 400 for invalid range ID format', async () => {
    const res = await request(app)
      .get('/api/ranges/invalididformat')
      .set('x-auth-token', authToken);
    expect(res.statusCode).toEqual(400);
    expect(res.body.message).toEqual('Virheellinen ampumaradan ID-muoto.');
  });

  it('should not get a single shooting range if not authenticated', async () => {
    const newRange = await ShootingRange.create({
      userId: testUser._id,
      name: 'Unauth Range',
      address: 'Unauth Street 4',
      location: { type: 'Point', coordinates: [27, 60] },
    });
    const res = await request(app)
      .get(`/api/ranges/${newRange._id}`);
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });
});
