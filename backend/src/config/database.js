const fs = require("fs");
const path = require("path");
const mysql = require("mysql2");
const mongoose = require("mongoose");
const config = require("./databaseConfig");

let db;

const runSchemaScript = () => {
  const schemaPath = path.join(__dirname, "../../db/schema.sql");
  const schema = fs.readFileSync(schemaPath, "utf-8");

  const checkTableExistsQuery = 'SHOW TABLES LIKE "Weapons"';
  db.query(checkTableExistsQuery, (err, results) => {
    if (err) {
      console.error("Error checking for table existence:", err.message);
      return;
    }
    if (results.length === 0) {
      db.query(schema, (err) => {
        if (err) {
          console.error("Error running schema script:", err.message);
          return;
        }
        console.log("Database schema initialized");
      });
    } else {
      console.log("Tables already exist. Skipping schema script.");
    }
  });
};

const connectDB = async () => {
  if (config.db.type === "mongodb") {
    try {
      await mongoose.connect(config.db.uri, {
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 1000,
      });
      console.log("Connected to MongoDB");
      db = mongoose;
    } catch (error) {
      console.error("Error connecting to MongoDB:", error.message);
    }
  } else if (config.db.type === "mysql") {
    db = mysql.createConnection({
      host: config.db.host,
      user: config.db.user,
      password: config.db.password,
      database: config.db.database,
    });

    db.connect((err) => {
      if (err) {
        console.error("Error connecting to MySQL:", err.stack);
        return;
      }
      console.log("Connected to MySQL");
      runSchemaScript();
    });
  }
};

module.exports = { connectDB, db };
