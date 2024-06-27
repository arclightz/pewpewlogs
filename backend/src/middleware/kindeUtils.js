// Middleware to check for specific permissions
const checkPermission = (permissionKey) => async (req, res, next) => {
  const permission = await kindeClient.getPermission(req, permissionKey);
  if (permission.isGranted) {
    next();
  } else {
    res.status(403).json({ message: 'Permission denied' });
  }
};

// Utility function to get all user permissions
const getUserPermissions = async (req) => {
  return await kindeClient.getPermissions(req);
};

// Utility function to get user's organization
const getUserOrganization = async (req) => {
  return await kindeClient.getOrganization(req);
};

// Utility function to get feature flags
const getFeatureFlag = async (req, flagCode, defaultValue) => {
  return await kindeClient.getFlag(req, flagCode, defaultValue);
};

// Middleware to handle logout
const handleLogout = (req, res) => {
  kindeClient.logout();
  res.redirect('/'); // Redirect to home page after logout
};

module.exports = {
  kindeClient,
  authenticateUser,
  checkPermission,
  getUserPermissions,
  getUserOrganization,
  getFeatureFlag,
  handleLogout
};