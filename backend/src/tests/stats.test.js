// backend/src/tests/stats.test.js
const request = require('supertest');
const app = require('../app');
const User = require('../models/users');
const Weapon = require('../models/weapons');
const ShootingRange = require('../models/shootingRanges');
const Session = require('../models/sessions');
const mongoose = require('mongoose');

// Load environment variables for tests
require('dotenv').config({ path: './.env' });
const TEST_USER_PASSWORD = process.env.TEST_USER_PASSWORD || 'testpassword123';

describe('Stats API', () => {
  let authToken;
  let testUser;
  let weapon1;
  let weapon2;
  let range1;

  beforeAll(async () => {
    // Create user and get token
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Stats Test User',
        email: 'stats.test@example.com',
        password: TEST_USER_PASSWORD,
      });
    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'stats.test@example.com',
        password: TEST_USER_PASSWORD,
      });
    authToken = loginRes.body.token;
    testUser = await User.findOne({ email: 'stats.test@example.com' });

    // Create weapons
    const weapon1Res = await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken)
      .send({ name: 'Pistooli A', type: 'Pistooli', caliber: '9mm', erva: false });
    weapon1 = await Weapon.findById(weapon1Res.body._id);

    const weapon2Res = await request(app)
      .post('/api/weapons')
      .set('x-auth-token', authToken)
      .send({ name: 'Kivääri B', type: 'Kivääri', caliber: '.223 Rem', erva: false });
    weapon2 = await Weapon.findById(weapon2Res.body._id);

    // Create range
    const rangeRes = await request(app)
      .post('/api/ranges')
      .set('x-auth-token', authToken)
      .send({ name: 'Stat Test Range', address: 'Stat Test Adress', latitude: 60, longitude: 25 });
    range1 = await ShootingRange.findById(rangeRes.body._id);

    // Create sessions for stats calculation
    await Session.create({
      userId: testUser._id,
      date: new Date('2025-05-01'),
      range: range1._id,
      weapon: weapon1._id,
      numberOfShotsFired: 100,
      hits: 90,
      misses: 10,
      type: 'Harjoitus',
      sportType: 'Precision Pistol',
      distanceToTarget: 25,
      result: '90',
      hitFactor: 2.0,
      compScore: 80,
    });
    await Session.create({
      userId: testUser._id,
      date: new Date('2025-05-02'),
      range: range1._id,
      weapon: weapon1._id,
      numberOfShotsFired: 50,
      hits: 40,
      misses: 10,
      type: 'Kilpailu',
      sportType: 'IPSC',
      distanceToTarget: 10,
      result: '40',
      hitFactor: 1.5,
      compScore: 70,
    });
    await Session.create({
      userId: testUser._id,
      date: new Date('2025-05-03'),
      range: range1._id,
      weapon: weapon2._id,
      numberOfShotsFired: 200,
      hits: 180,
      misses: 20,
      type: 'Harjoitus',
      sportType: 'Long Range',
      distanceToTarget: 300,
      result: '180',
    });
  });

  // Test getting overall stats
  it('should get overall statistics for the authenticated user', async () => {
    const res = await request(app)
      .get('/api/stats')
      .set('x-auth-token', authToken);

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('overall');
    expect(res.body).toHaveProperty('shotsPerWeapon');

    expect(res.body.overall.totalSessions).toEqual(3);
    expect(res.body.overall.totalShotsFired).toEqual(350);
    expect(res.body.overall.totalHits).toEqual(310);
    expect(res.body.overall.totalMisses).toEqual(40);
    // Accuracy = (310 / 350) * 100
    expect(res.body.overall.accuracyPercentage).toBeCloseTo(88.57);
  });

  it('should get shots per weapon statistics', async () => {
    const res = await request(app)
      .get('/api/stats')
      .set('x-auth-token', authToken);

    expect(res.statusCode).toEqual(200);
    expect(res.body.shotsPerWeapon).toHaveLength(2); // Pistol A and Rifle B

    const pistolStats = res.body.shotsPerWeapon.find(s => s.weaponName === 'Pistooli A');
    expect(pistolStats.totalShots).toEqual(150);
    expect(pistolStats.totalSessions).toEqual(2);

    const rifleStats = res.body.shotsPerWeapon.find(s => s.weaponName === 'Kivääri B');
    expect(rifleStats.totalShots).toEqual(200);
    expect(rifleStats.totalSessions).toEqual(1);
  });

  it('should return default stats if no sessions exist for the user', async () => {
    // Create a new user with no sessions
    await request(app)
      .post('/api/auth/register')
      .send({ name: 'Empty Stats User', email: 'empty.stats@example.com', password: TEST_USER_PASSWORD });
    const emptyUserLoginRes = await request(app)
      .post('/api/auth/login')
      .send({ email: 'empty.stats@example.com', password: TEST_USER_PASSWORD });
    const emptyUserToken = emptyUserLoginRes.body.token;

    const res = await request(app)
      .get('/api/stats')
      .set('x-auth-token', emptyUserToken);

    expect(res.statusCode).toEqual(200);
    expect(res.body.overall.totalSessions).toEqual(0);
    expect(res.body.overall.totalShotsFired).toEqual(0);
    expect(res.body.overall.accuracyPercentage).toEqual(0);
    expect(res.body.shotsPerWeapon).toHaveLength(0);
  });

  it('should not get statistics if not authenticated', async () => {
    const res = await request(app)
      .get('/api/stats');
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });
});
