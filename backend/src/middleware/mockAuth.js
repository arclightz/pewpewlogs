const mockAuthenticateUser = (req, res, next) => {
    req.user = { id: 696969, kindeId: 'test-kinde-id', email: 'test@example.com' };
    next();
  };