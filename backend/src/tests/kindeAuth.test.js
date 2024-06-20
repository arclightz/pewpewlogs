const request = require('supertest');
const express = require('express');
const app = express();
const registerRouter = require('../routes/kindeAuth');
app.use('/register', registerRouter);

describe('Register Routes', () => {
  it('should redirect to register URL', async () => {
    const response = await request(app).get('/register');
    expect(response.statusCode).toBe(302);
    expect(response.header.location).toMatch(process.env.KINDE_ISSUER_URL);
    expect(response.header.location).toMatch(process.env.KINDE_CLIENT_ID);
    expect(response.header.location).toMatch(process.env.KINDE_REDIRECT_URL);
    expect(response.header.location).toMatch('scope=openid%20profile%20email');
    // You can add more assertions if needed
  });
});