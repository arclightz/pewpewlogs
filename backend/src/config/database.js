const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const config = require('./databaseConfig');

let db;

const runSchemaScript = async () => {
  const schemaPath = path.join(__dirname, '../../db/schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf-8');

  try {
    const [results] = await db.query('SHOW TABLES LIKE "Weapons"');
    if (results.length === 0) {
      await db.query(schema);
      console.log('Database schema initialized');
    } else {
      console.log('Tables already exist. Skipping schema script.');
    }
  } catch (err) {
    console.error('Error running schema script:', err.message);
  }
};

const connectDB = async () => {
  try {
    db = await mysql.createConnection({
      host: config.db.host,
      user: config.db.user,
      password: config.db.password,
      database: config.db.database,
    });
    console.log('Connected to MySQL');
    await runSchemaScript();
  } catch (err) {
    console.error('Error connecting to MySQL:', err.message);
  }
};

module.exports = { connectDB, db };
