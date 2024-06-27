require("dotenv").config();
const request = require('supertest');
const { sequelize, connectDB } = require('../config/database');
const app = require('../app');
const { Session, Weapons } = require('../models');

describe('Sessions API', () => {
  let authToken;

  beforeAll(async () => {
    // Perform authentication and obtain the auth token
    process.env.NODE_ENV = 'test';

    await connectDB();

    const response = await request(app)
      .post('/auth/login')
      .send({ email: process.env.TESTUSER, password: process.env.TESTPWD });
    authToken = response.body.token;

    // Create test sessions (if required)
    await Session.bulkCreate([
      { userId: 1, date: new Date(), notes: 'Test session 1' },
      { userId: 1, date: new Date(), notes: 'Test session 2' },
    ]);
  });



  describe('GET /sessions', () => {
    it('should return all sessions for the current user', async () => {
      const response = await request(app)
        .get('/sessions')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(2); // Assuming there are 2 sessions for the user
      // Add more assertions as needed
    });

    it('should return an error if retrieving sessions fails', async () => {
      // Mock the Session.findAll() method to throw an error
      jest.spyOn(Session, 'findAll').mockRejectedValueOnce(new Error('Database error'));
      const response = await request(app)
        .get('/sessions')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(500);
      expect(response.body).toEqual({ message: 'Error retrieving sessions', error: 'Database error' });
    });
  });

  describe('GET /sessions/:id', () => {
    it('should return a specific session for the current user', async () => {
      const response = await request(app)
        .get('/sessions/1')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(200);
      expect(response.body.id).toBe(1); // Assuming session with ID 1 exists for the user
      // Add more assertions as needed
    });

    it('should return an error if session is not found', async () => {
      // Mock the Session.findOne() method to return null
      jest.spyOn(Session, 'findOne').mockResolvedValueOnce(null);
      const response = await request(app)
        .get('/sessions/1')
        .set('Authorization', `Bearer ${authToken}`);
      
      expect(response.status).toBe(404);
      expect(response.body).toEqual({ message: 'Session not found' });
    });
  });

  afterAll(async () => {
    await sequelize.close();
  });
  // Add tests for other routes (POST, PUT, DELETE) in a similar manner
});
