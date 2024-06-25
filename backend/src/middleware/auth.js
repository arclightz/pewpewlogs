require("dotenv").config();
const { KindeClient, GrantType } = require("@kinde-oss/kinde-nodejs-sdk");
const { User } = require("../models");

const options = {
  domain: process.env.KINDE_DOMAIN,
  clientId: process.env.KINDE_CLIENT_ID,
  clientSecret: process.env.KINDE_CLIENT_SECRET,
  redirectUri: process.env.KINDE_REDIRECT_URI,
  postLoginRedirectUri: process.env.KINDE_POST_LOGIN_REDIRECT_URI || '',
  logoutRedirectUri: process.env.KINDE_LOGOUT_REDIRECT_URI || '',
  grantType: GrantType.PKCE,
};

const kindeClient = new KindeClient(options);

const authenticateUser = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (authHeader) {
    const token = authHeader.split(' ')[1];
    try {
      const decodedToken = await kindeClient.verifyToken(token);
      const [user] = await User.findOrCreate({
        where: { kindeId: decodedToken.sub },
        defaults: {
          email: decodedToken.email,
          firstName: decodedToken.given_name,
          lastName: decodedToken.family_name,
        }
      });
      if (user) {
        req.user = user;
        next();
      } else {
        res.status(401).json({ message: 'User not found' });
      }
    } catch (error) {
      console.error('Token verification error:', error);
      res.status(401).json({ message: 'Invalid token' });
    }
  } else {
    res.status(401).json({ message: 'Authorization header is missing' });
  }
};

module.exports = { kindeClient, authenticateUser };