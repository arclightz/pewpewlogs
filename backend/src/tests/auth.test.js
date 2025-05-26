// backend/src/tests/auth.test.js
const request = require('supertest');
const app = require('../app'); // Import your Express app instance
const User = require('../models/users'); // Import your User model

// IMPORTANT: Load environment variables for tests
require('dotenv').config({ path: './.env' }); // Adjust path if .env is in project root

// Use environment variables for test credentials or secrets if needed
const TEST_USER_PASSWORD = process.env.TEST_USER_PASSWORD || 'testpassword123';
const TEST_JWT_SECRET = process.env.JWT_SECRET || '5b8f0e3c7d9e4aefb1c0f46a7c13d29e8c45e14f9b11ab4e2c8f7d16bc9a3d5e'; // Ensure this matches your auth middleware

describe('Auth API', () => {
  // Test User registration
  it('should register a new user successfully', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test User',
        email: 'test@example.com',
        password: TEST_USER_PASSWORD, // Using variable
      });
    expect(res.statusCode).toEqual(201);
    expect(res.body.message).toEqual('User registered successfully. Please log in.');

    // Verify user exists in DB
    const user = await User.findOne({ email: 'test@example.com' });
    expect(user).not.toBeNull();
    expect(user.email).toEqual('test@example.com');
  });

  it('should not register a user with existing email', async () => {
    // Create a user first
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Existing User',
        email: 'existing@example.com',
        password: TEST_USER_PASSWORD,
      });

    // Try to register again with same email
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Another User',
        email: 'existing@example.com',
        password: 'newpassword',
      });
    expect(res.statusCode).toEqual(400);
    expect(res.body.message).toEqual('User with that email already exists');
  });

  // Test User login
  it('should log in an existing user and return a token', async () => {
    // Register a user first to log in
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Login User',
        email: 'login@example.com',
        password: TEST_USER_PASSWORD,
      });

    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'login@example.com',
        password: TEST_USER_PASSWORD,
      });
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('token');
    expect(res.body.user.email).toEqual('login@example.com');
  });

  it('should not log in with invalid credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'nonexistent@example.com',
        password: 'wrongpassword',
      });
    expect(res.statusCode).toEqual(400);
    expect(res.body.message).toEqual('Invalid credentials');
  });

  // Test GET /api/auth/me (protected route)
  it('should get authenticated user details', async () => {
    // Register and login a user to get a token
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Auth User',
        email: 'auth@example.com',
        password: TEST_USER_PASSWORD,
      });

    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'auth@example.com',
        password: TEST_USER_PASSWORD,
      });
    const token = loginRes.body.token;

    // Make a request to /api/auth/me with the token
    const res = await request(app)
      .get('/api/auth/me')
      .set('x-auth-token', token); // Set the token in header
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.user).toHaveProperty('id');
    expect(res.body.user.email).toEqual('auth@example.com');
    expect(res.body.user).not.toHaveProperty('password'); // Should not return password
  });

  it('should not get authenticated user details without a token', async () => {
    const res = await request(app)
      .get('/api/auth/me'); // No token sent
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token, authorization denied');
  });

  it('should not get authenticated user details with an invalid token', async () => {
    const res = await request(app)
      .get('/api/auth/me')
      .set('x-auth-token', 'invalid_jwt_token'); // Invalid token
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('Token is not valid');
  });
});
