const express = require('express');
const router = express.Router();
const { GrantType, KindeClient } = require('@kinde-oss/kinde-nodejs-sdk');
const { isAuthenticated } = require('../middleware/isAuthenticated');

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

router.get('/login', kindeClient.login(), (req, res) => {
  return res.redirect('/admin');
});

router.get('/callback', kindeClient.callback(), async (req, res) => {
  return res.redirect('/admin');
});

router.get('/register', kindeClient.register(), (req, res) => {
  return res.redirect('/admin');
});

router.get('/createOrg', kindeClient.createOrg(), (req, res) => {
  return res.redirect('/admin');
});

router.get('/logout', kindeClient.logout());

router.get('/helper-functions', isAuthenticated(kindeClient), (req, res) => {
  res.render('helper_functions', {
    user: kindeClient.getUserDetails(req)
  });
});

router.get('/user-detail', isAuthenticated(kindeClient), async (req, res) => {
  const accessToken = await kindeClient.getToken(req);
  res.render('details', {
    user: kindeClient.getUserDetails(req),
    accessToken: accessToken
  });
});

router.get('/get-claim-view', isAuthenticated(kindeClient), (req, res) => {
  const result = kindeClient.getClaim(req, 'given_name', 'id_token');
  res.render('get_claim', {
    user: kindeClient.getUserDetails(req),
    resultGetClaim: JSON.stringify(result)
  });
});

router.get('/get-flag-view', isAuthenticated(kindeClient), (req, res) => {
  const result = kindeClient.getFlag(req, 'theme', { defaultValue: false }, 's');
  res.render('get_flag', {
    user: kindeClient.getUserDetails(req),
    resultGetFlag: JSON.stringify(result),
  });
});

router.get('/get-permissions-view', isAuthenticated(kindeClient), (req, res) => {
  res.render('get_permissions', {
    user: kindeClient.getUserDetails(req),
    resultGetPermissions: JSON.stringify(kindeClient.getPermissions(req))
  });
});

router.get('/get-permission-view', isAuthenticated(kindeClient), (req, res) => {
  res.render('get_permission', {
    user: kindeClient.getUserDetails(req),
  });
});

router.post('/get-permission', isAuthenticated(kindeClient), (req, res) => {
  try {
    const { permission } = req.body;
    const result = kindeClient.getPermission(req, permission);
    if (result) {
      res.render('get_permission', { user: kindeClient.getUserDetails(req), resultGetPermission: JSON.stringify(result) });
    }
  } catch (e) {
    res.render('get_permission', { user: kindeClient.getUserDetails(req), errorGetPermission: e.message });
  }
});

router.get('/get-organization-view', isAuthenticated(kindeClient), (req, res) => {
  res.render('get_organization', {
    user: kindeClient.getUserDetails(req),
    resultGetOrganization: JSON.stringify(kindeClient.getOrganization(req))
  });
});

router.get('/get-user-organization-view', isAuthenticated(kindeClient), (req, res) => {
  res.render('get_user_organizations', {
    user: kindeClient.getUserDetails(req),
    resultGetUserOrganizations: JSON.stringify(kindeClient.getUserOrganizations(req))
  });
});

router.get('/get-token-view', isAuthenticated(kindeClient), async (req, res) => {
  const token = await kindeClient.getToken(req);
  res.render('get_token', {
    user: kindeClient.getUserDetails(req),
    resultGetToken: token
  });
});

router.get('/', async (req, res) => {
  const isAuthenticated = await kindeClient.isAuthenticated(req);
  if (isAuthenticated) {
    res.redirect('/admin');
  } else {
    res.render('index', {
      title: 'Hey',
      message: 'Hello there! what would you like to do?',
    });
  }
});

router.get('/admin', isAuthenticated(kindeClient), (req, res) => {
  res.render('admin', {
    title: 'Admin',
    user: kindeClient.getUserDetails(req),
  });
});

module.exports = router;