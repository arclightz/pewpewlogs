const request = require('supertest');
const express = require('express');
const authRouter = require('../routes/auth');
const User = require('../models/userSchema');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());
app.use('/auth', authRouter);

describe('Auth Routes', () => {
  beforeAll(async () => {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  it('should register a new user', async () => {
    const response = await request(app)
      .post('/auth/register')
      .send({ username: 'testuser', email: 'testuser@example.com', password: 'password' });
    expect(response.statusCode).toBe(201);
    expect(response.body.message).toBe('User registration successful');
  });

  it('should fail to authenticate with wrong credentials', async () => {
    const response = await request(app)
      .post('/auth/login')
      .send({ email: 'wrong@example.com', password: 'wrongpassword' });
    expect(response.statusCode).toBe(401);
    expect(response.body.message).toBe('Authentication failed');
  });
});it('should return a valid token upon successful login', async () => {
  const response = await request(app)
    .post('/auth/login')
    .send({ email: 'testuser@example.com', password: 'password' });
  expect(response.statusCode).toBe(200);
  expect(response.body.token).toBeDefined();
});