const request = require('supertest');
const express = require('express');
const app = express();
const protectRouteRouter = require('../routes/protectRoute');
const jwt = require('jsonwebtoken');

app.use('/protected', protectRouteRouter);

describe('Protected Route', () => {
  it('should return 401 if no token provided', async () => {
    const response = await request(app).get('/protected');
    expect(response.statusCode).toBe(401);
  });

  it('should return 401 if invalid token provided', async () => {
    const token = jwt.sign({ userId: '123' }, 'invalidSecret');
    const response = await request(app)
      .get('/protected')
      .set('Authorization', `Bearer ${token}`);
    expect(response.statusCode).toBe(401);
  });

  it('should return 200 if valid token provided', async () => {
    const token = jwt.sign({ userId: '123' }, process.env.JWT_SECRET);
    const response = await request(app)
      .get('/protected')
      .set('Authorization', `Bearer ${token}`);
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ message: 'Protected route accessed' });
  });
});