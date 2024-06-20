import globals from 'globals';
import pluginJs from '@eslint/js';

export default [
  {
    files: ['**/*.js'],
    languageOptions: {
      sourceType: 'commonjs',
      ecmaVersion: 2020,
      globals: {
        ...globals.node,
        ...globals.jest, // Add Jest globals
      },
    },
    rules: {
      'no-console': 'off', // Allow console.log statements
      'no-unused-vars': ['error', { argsIgnorePattern: 'next' }], // Ignore unused `next` parameter
    },
  },
  {
    languageOptions: {
      globals: globals.browser,
    },
  },
  pluginJs.configs.recommended,
];