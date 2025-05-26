// backend/jest.config.js
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/src/tests/testSetup.js'],
  testMatch: ['<rootDir>/src/tests/**/*.test.js'],
  moduleFileExtensions: ['js', 'json', 'node'],
  // FIX: Removed preset as we are connecting directly to Docker MongoDB
  // preset: '@shelf/jest-mongodb', // REMOVED
  watchPathIgnorePatterns: ['globalConfig'],
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: ['<rootDir>/src/**/*.js', '!<rootDir>/src/server.js', '!<rootDir>/src/app.js', '!<rootDir>/src/config/**/*.js', '!<rootDir>/src/tests/**/*.js'],
};
