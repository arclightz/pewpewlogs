const { sequelize } = require('../models');

beforeAll(async () => {
  // Sync the database before running tests
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  // Close the database connection after all tests are done
  await sequelize.close();
});
