console.log(`Current directory: ${process.cwd()}`);
require("dotenv").config();
const { kindeClient, authenticateUser } = require('./middleware/auth');
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
const proxyRouter = require("./routes/proxy");

// Database initialization
const { connectDB } = require("./config/database");

// Middleware to initialize Kinde client
app.use((req, res, next) => {
  req.kindeClient = kindeClient;
  next();
});

// Kinde login route
app.get('/login', (req, res) => {
  res.redirect(req.kindeClient.getLoginUrl());
});

// Kinde callback route
app.get('/callback', async (req, res) => {
  try {
    const tokens = await req.kindeClient.getTokens(req.url);
    // Store tokens securely (e.g., in a secure httpOnly cookie)
    res.cookie('kinde_token', tokens.access_token, { httpOnly: true, secure: true });
    res.redirect('/dashboard'); // Redirect to your app's dashboard
  } catch (error) {
    console.error('Error in Kinde callback:', error);
    res.status(500).send('Authentication failed');
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
    cookie: { secure: false }, // True if using HTTPS
  }),
);

app.use("/api/users", usersRouter);
// app.use("/api/auth", authRouter);
app.use("/api/sessions", sessionRouter);
app.use("/api/stats", statsRouter);
app.use("/api/weapons", weaponsRouter);
app.use('/api', proxyRouter);

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
