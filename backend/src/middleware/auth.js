require("dotenv").config();
const { KindeClient, GrantType } = require("@kinde-oss/kinde-nodejs-sdk");
const { User } = require("../models");

const options = {
  domain: process.env.KINDE_DOMAIN,
  clientId: process.env.KINDE_CLIENT_ID,
  clientSecret: process.env.KINDE_CLIENT_SECRET,
  redirectUri: process.env.KINDE_REDIRECT_URI,
  postLoginRedirectUri: process.env.KINDE_POST_LOGIN_REDIRECT_URI || '',
  logoutRedirectUri: process.env.KINDE_LOGOUT_REDIRECT_URI || '/token',
  //grantType: GrantType.PKCE,
  grantType: 'authorization_code', // Make sure this is set
};

const kindeClient = new KindeClient(options);

const authenticateUser = async (req, res, next) => {
  try {
    const isAuthenticated = await kindeClient.isAuthenticated(req);
    
    if (!isAuthenticated) {
      console.log('User not authenticated. Token might be missing or invalid.');
      return res.status(401).json({ message: 'User not authenticated' });
    }

    const kindeUser = await kindeClient.getUserDetails(req);

    if (!kindeUser) {
      return res.status(401).json({ message: 'Unable to retrieve user details' });
    }

    const [user, created] = await User.findOrCreate({
      where: { kindeId: kindeUser.id },
      defaults: {
        email: kindeUser.email,
        firstName: kindeUser.given_name,
        lastName: kindeUser.family_name,
      }
    });

    if (created) {
      console.log('New user created:', user.email);
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    res.status(401).json({ message: 'Authentication failed' });
  }
};

module.exports = { kindeClient, authenticateUser };