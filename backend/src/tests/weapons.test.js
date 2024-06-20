const mongoose = require('mongoose');
const request = require('supertest');
const app = require('../app');
const Weapon = require('../models/weaponSchema');

beforeEach(async () => {
  // Clear the weapons collection before each test
  await Weapon.deleteMany({});
})

describe('POST /weapons', () => {
  it('should create a new weapon', async () => {
    const weaponData = {
      name: 'Test Weapon',
      type: 'Test Type',
      caliber: 'Test Caliber',
      toimintatapa: 'Test Toimintatapa',
      erva: true
    };

    const response = await request(app)
      .post('/weapons')
      .send(weaponData);

    // For debug
    // console.log('Response status:', response.status); // Log status
    // console.log('Response body:', response.body); // Log body

    expect(response.status).toBe(201);
    expect(response.text).toContain('New weapon created with ID');

    // Verify that the weapon is saved in the database
    const savedWeapon = await Weapon.findOne({ name: weaponData.name });
    // For debug
    // console.log('Saved Weapon:', savedWeapon);
    expect(savedWeapon).toBeTruthy();
    expect(savedWeapon.type).toBe(weaponData.type);
    expect(savedWeapon.caliber).toBe(weaponData.caliber);
    expect(savedWeapon.toimintatapa).toBe(weaponData.toimintatapa);
    expect(savedWeapon.erva).toBe(weaponData.erva);
  });

  // Add more test cases if needed

  // After all tests are done, disconnect Mongoose
  afterAll(async () => {
    await mongoose.disconnect();
  });

});