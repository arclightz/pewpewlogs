const express = require('express');
const axios = require('axios');
const router = express.Router();

router.get('/proxy/openid-configuration', async (req, res) => {
  try {
    const response = await axios.get('https://arclightsec-warpcore.eu.kinde.com/.well-known/openid-configuration');
    res.json(response.data);
  } catch (error) {
    res.status(error.response ? error.response.status : 500).send(error.message);
  }
});

module.exports = router;
