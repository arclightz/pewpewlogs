const { Sequelize } = require('sequelize');
const config = require('./databaseConfig');

const sequelize = new Sequelize(config.db.database, config.db.user, config.db.password, {
  host: config.db.host,
  dialect: 'mysql',
  logging: false // Set to console.log to see the SQL queries
});

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('Connected to MariaDB');
    await sequelize.sync(); // This will create tables if they don't exist
    console.log('Database synchronized');
  } catch (err) {
    console.error('Error connecting to MariaDB:', err.message);
  }
};

module.exports = { sequelize, connectDB };