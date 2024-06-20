console.log(`Current directory: ${process.cwd()}`);
require("dotenv").config();
const kindeClient = require("./middleware/kindeClient"); // Import the Kinde client
const createError = require("http-errors");
const express = require("express");
const session = require("express-session");
const app = express();

const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");

const indexRouter = require("./routes/index");
const usersRouter = require("./routes/users");
const authRouter = require("./routes/kindeAuth"); // Include the auth router
const protectedRoute = require("./routes/protectRoute"); // Include the protected route
const sessionRouter = require("./routes/sessions"); // Include the session router
const statsRouter = require("./routes/stats"); // Include the stats router
const weaponsRouter = require("./routes/weapons");

const { connectDB } = require("./config/database");
connectDB();

// Middleware to initialize Kinde client
app.use((req, res, next) => {
  req.kindeClient = kindeClient;
  next();
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
    secret: "kdqp5vQLz72pgRLu9mf0CQB4FdFQNfFWpXaZOuh7",
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false }, // True if using HTTPS
  }),
);

app.use("/", indexRouter);
app.use("/", usersRouter);
app.use("/protected", protectedRoute);
app.use("/", authRouter);
app.use("/sessions", sessionRouter);
app.use("/stats", statsRouter);
app.use("/weapons", weaponsRouter);
app.get('/logout', kindeClient.logout());

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
