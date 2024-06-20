const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const User = require('../models/userSchema');
const app = express();
app.use(express.json());
const userRouter = require('../routes/users');
app.use('/users', userRouter);

describe('User Routes', () => {
  beforeAll(async () => {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
  });

  afterAll(async () => {
    await mongoose.disconnect();
  });

  beforeEach(async () => {
    // Clear the user collection before each test
    await User.deleteMany();
  });

  it('should get user profile', async () => {
    const newUser = new User({
      username: 'testuser',
      email: 'testuser@example.com',
      password: 'password',
    });
    await newUser.save();

    const response = await request(app)
      .get('/users/profile')
      .set('Authorization', `Bearer ${token}`); // Assuming you have implemented authentication middleware

    expect(response.statusCode).toBe(200);
    expect(response.body.username).toBe('testuser');
    expect(response.body.email).toBe('testuser@example.com');
  });

  it('should update user profile', async () => {
    const newUser = new User({
      username: 'testuser',
      email: 'testuser@example.com',
      password: 'password',
    });
    await newUser.save();

    const updatedUser = {
      username: 'updateduser',
      email: 'updateduser@example.com',
    };

    const response = await request(app)
      .put('/users/profile')
      .set('Authorization', `Bearer ${token}`) // Assuming you have implemented authentication middleware
      .send(updatedUser);

    expect(response.statusCode).toBe(200);
    expect(response.body.username).toBe('updateduser');
    expect(response.body.email).toBe('updateduser@example.com');
  });
});