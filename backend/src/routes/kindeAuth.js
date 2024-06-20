const express = require("express");
const router = express.Router();
const kindeClient = require("../middleware/kindeClient");
const crypto = require("crypto");

// Function to generate a secure random state parameter
function generateState(length = 32) {
  const state = crypto.randomBytes(length).toString("hex").slice(0, length);
  console.log(`Generated state: ${state} with length: ${state.length}`);
  return state;
}

// Route for login
router.get("/login", (req, res) => {
  const state = generateState(16); // Ensuring 16-byte state, which is 32 characters hex
  req.session.oauthState = state; // Store the state in the session

  if (state.length < 8) {
    return res.status(500).send("State parameter is too short");
  }

  const loginUrl = `${process.env.KINDE_ISSUER_URL}/authorize?client_id=${process.env.KINDE_CLIENT_ID}&response_type=code&redirect_uri=${process.env.KINDE_REDIRECT_URL}&scope=openid%20profile%20email&state=${state}`;
  console.log(`Redirecting to login URL: ${loginUrl}`);
  res.redirect(loginUrl);
});

// Route for register
router.get("/register", (req, res) => {
  const state = generateState(16); // Ensuring 16-byte state, which is 32 characters hex
  req.session.oauthState = state; // Store the state in the session

  if (state.length < 8) {
    return res.status(500).send("State parameter is too short");
  }

  const registerUrl = `${process.env.KINDE_ISSUER_URL}/register?client_id=${process.env.KINDE_CLIENT_ID}&response_type=code&redirect_uri=${process.env.KINDE_REDIRECT_URL}&scope=openid%20profile%20email&state=${state}`;
  console.log(`Redirecting to register URL: ${registerUrl}`);
  res.redirect(registerUrl);
});

// Callback route for authentication
router.get("/callback", async (req, res) => {
  try {
    const { code, state } = req.query;
    console.log(`Received state: ${state} with length: ${state.length}`);
    console.log(`Session state: ${req.session.oauthState}`);

    if (state !== req.session.oauthState) {
      return res.status(403).send("Invalid state parameter");
    }
    delete req.session.oauthState; // Clear the state from the session

    const tokenSet = await kindeClient.callback(code, {
      redirectUri: process.env.KINDE_REDIRECT_URL,
    });

    if (!tokenSet) {
      return res.status(500).send("Failed to obtain token set");
    }

    req.session.tokenSet = tokenSet;
    console.log(`Token set stored in session: ${JSON.stringify(tokenSet)}`);

    res.redirect("/users/profile");
  } catch (error) {
    console.error("Callback error:", error);
    res.status(500).send("Authentication callback failed");
  }
});

module.exports = router;