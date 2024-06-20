module.exports = {
    env: {
      node: true, // Recognize Node.js globals
      es6: true,
    },
    extends: [
      'eslint:recommended',
      'airbnb-base',
    ],
    parserOptions: {
      ecmaVersion: 2020,
      sourceType: 'script', // Use 'module' if you switch to ES modules
    },
    rules: {
      'no-console': 'off', // Allow console.log statements
      'no-unused-vars': ['error', { argsIgnorePattern: 'next' }], // Ignore unused `next` parameter
      'no-undef': 'off', // Turn off no-undef for Node.js globals like process and __dirname
      'linebreak-style': 'off', // Disable linebreak-style to avoid issues between Windows and Unix systems
      // Add other custom rules as needed
    },
  };