require("dotenv").config();

const config = {
  development: {
    db: {
      host: process.env.MYSQL_HOSTNAME,
      user: process.env.MYSQL_USERNAME,
      password: process.env.MYSQL_PASSWORD,
      database: process.env.MYSQL_DATABASE,
      type: "mysql",
    },
  },
  test: {
    db: {
      host: process.env.TEST_MYSQL_HOSTNAME,
      user: process.env.MYSQL_USERNAME,
      password: process.env.MYSQL_PASSWORD,
      database: process.env.MYSQL_DATABASE_TEST || "pewpew_test",
      port: process.env.MYSQL_PORT || 3306,
      type: process.env.DB_TYPE || "mysql",
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
