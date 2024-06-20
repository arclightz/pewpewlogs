require("dotenv").config();

const config = {
  development: {
    db: {
      type: process.env.DB_TYPE || 'mongodb',
      uri: process.env.MONGODB_URI,
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,
    },
  },
  production: {
    db: {
      host: process.env.RDS_HOSTNAME,
      user: process.env.RDS_USERNAME,
      password: process.env.RDS_PASSWORD,
      database: process.env.RDS_DATABASE,
      type: "mysql",
    },
  },
};

const environment = process.env.NODE_ENV || "development";
const envConfig = config[environment];

module.exports = envConfig;
