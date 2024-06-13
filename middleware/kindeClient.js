require('dotenv').config();
const express = require("express");

const { KindeClient, GrantType } = require('@kinde-oss/kinde-nodejs-sdk');

const options = {
  domain: process.env.KINDE_ISSUER_URL,
  clientId: process.env.KINDE_CLIENT_ID,
  clientSecret: process.env.KINDE_CLIENT_SECRET,
  redirectUri: process.env.KINDE_REDIRECT_URL,
  logoutRedirectUri: process.env.KINDE_LOGOUT_REDIRECT_URL,
  grantType: GrantType.PKCE
};

const kindeClient = new KindeClient(options);


module.exports = kindeClient;
