console.log(`Current directory: ${process.cwd()}`);
require("dotenv").config();
const { kindeClient } = require('./middleware/auth');
const { isAuthenticated } = require('./middleware/isAuthenticated');
const createError = require("http-errors");
const express = require("express");
const session = require("express-session");
const app = express();

const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");

// Routers
const usersRouter = require("./routes/users");
const sessionRouter = require("./routes/sessions"); 
const statsRouter = require("./routes/stats");
const weaponsRouter = require("./routes/weapons");
const tokenRoutes = require('./routes/token');

// Database initialization not needed here?
const { connectDB } = require("./config/database");

connectDB().then(() => {
  console.log('Connected to database');
}).catch(err => {
  console.error('Database connection failed', err);
  process.exit(1);
});
// Middleware to initialize Kinde client
app.use((req, res, next) => {
  req.kindeClient = kindeClient;
  next();
});
console.log(Object.keys(kindeClient));
// Kinde login route

app.get("/login", kindeClient.login(), (req, res) => {
  return res.redirect("/");
});

app.get("/register", kindeClient.register(), (req, res) => {
  return res.redirect("/");
});

app.get("/callback", kindeClient.callback(), (req, res) => {
  try {
    return res.redirect("/");
  } catch (error) {
    console.error("Error in Kinde callback:", error);
    return res.status(500).send("Authentication failed");
    }
});


// Kinde logout route
app.get('/logout', (req, res) => {
  res.clearCookie('kinde_token');
  res.redirect(req.kindeClient.getLogoutUrl());
});

// view engine setup
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "pug");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));

app.use(
  session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: { secure: true }, // True if using HTTPS
  }),
);

app.use("/api/users", usersRouter);
app.use("/api/sessions", sessionRouter);
app.use("/api/stats", statsRouter);
app.use("/api/weapons", weaponsRouter);

// For token retrieval
app.use('/api/token', tokenRoutes);

// Debug route for auth debugging
app.get('/debug-auth', async (req, res) => {
  console.log('Debug: All Headers:', req.headers);
  console.log('Debug: Authorization Header:', req.headers.authorization);
  
  try {
    const isAuthenticated = await kindeClient.isAuthenticated(req);
    console.log('Debug: isAuthenticated:', isAuthenticated);
    
    if (isAuthenticated) {
      const userDetails = await kindeClient.getUserDetails(req);
      console.log('Debug: User Details:', userDetails);
      res.json({ isAuthenticated, userDetails });
    } else {
      res.json({ isAuthenticated, message: 'User is not authenticated' });
    }
  } catch (error) {
    console.error('Debug: Authentication Error:', error);
    res.status(500).json({ error: 'Authentication check failed' });
  }
});

// DEBUG: Route to check session state
app.get('/session-check', (req, res) => {
  res.json({
    sessionExists: !!req.session,
    tokenSetExists: !!req.session.tokenSet,
    sessionContent: req.session
  });
});


// Error handler for JWT authentication
app.use((err, req, res, next) => {
  if (err.name === 'UnauthorizedError') {
    res.status(401).json({ message: 'Invalid token' });
  } else {
    next(err);
  }
});

// catch 404 and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get("env") === "development" ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render("error");
});

module.exports = app;
