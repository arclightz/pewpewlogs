require("dotenv").config();
const { KindeClient, GrantType } = require("@kinde-oss/kinde-nodejs-sdk");

const options = {
  domain: process.env.KINDE_ISSUER_URL,
  clientId: process.env.KINDE_CLIENT_ID,
  clientSecret: process.env.KINDE_CLIENT_SECRET,
  redirectUri: process.env.KINDE_REDIRECT_URL,
  logoutRedirectUri: process.env.KINDE_LOGOUT_REDIRECT_URL,
  grantType: GrantType.PKCE,
};

const kindeClient = new KindeClient(options);

kindeClient.getUserDetails = (accessToken) => {
  try {
    const user = kindeClient.getUser(accessToken);
    return user;
  } catch (err) {
    console.error("Error fetching user details:", err);
    return null;
  }
};

kindeClient.callback = async (code, options) => {
  try {
    const tokenSet = await kindeClient.exchangeCode(code, options);
    return tokenSet;
  } catch (err) {
    console.error("Error exchanging code for tokens:", err);
    return null;
  }
};

module.exports = kindeClient;
