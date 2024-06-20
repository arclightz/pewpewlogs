const kindeClient = require("./kindeClient");

function verifyToken(req, res, next) {
  const tokenSet = req.session.tokenSet // Retrieve token from session
  console.log("Token set received from session:", tokenSet);

  if (!tokenSet) {
    return res.status(401).json({ message: "Access vittu denied" });
  }

  try {
    const user = kindeClient.getUserDetails(tokenSet.access_token);
    console.log("User details fetched:", user);
    if (!user) {
      return res.status(401).json({ message: "Invalid token" });
    }
    req.user = user;
    next();
  } catch (err) {
    console.error("Error verifying token:", err);
    res.status(401).json({ message: "Invalid token" });
  }
}

module.exports = verifyToken;