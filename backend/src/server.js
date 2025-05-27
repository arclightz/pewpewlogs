// backend/src/server.js
const app = require('./app'); // Import your Express app instance
const debug = require('debug')('pewpewlogs:server'); // For detailed debugging logs
const http = require('http'); // Node's built-in HTTP server module
// Import the connectDB function from your database configuration
// Assuming database.js exports an object with a connectDB property, or it's a named export.
const connectDB = require('./config/database');
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config({ path: './.env' }); // Adjust path if .env is in backend folder
}

// --- Database Connection ---
// Execute the database connection function.
// The server will only start listening if the database connection is successful.
connectDB()
  .then(() => {
    console.log('MongoDB Connected successfully!');
  })
  .catch((err) => {
    console.error('Database connection failed:', err.message);
    process.exit(1); // Exit the process if database connection fails
  });

// --- Server Setup ---
// Normalize the port to ensure it's a valid number or pipe.
const port = normalizePort(process.env.PORT || '3000');
app.set('port', port); // Set the port on the Express app instance

const server = http.createServer(app); // Create an HTTP server using the Express app

server.listen(port); // Start the server and listen for incoming requests on the specified port
server.on('error', onError); // Register an event listener for server errors
server.on('listening', onListening); // Register an event listener for when the server starts listening

// --- Helper Functions ---

/**
 * Normalize a port into a number, string, or false.
 * @param {string} val - The port value from environment variables.
 * @returns {number|string|boolean} - Normalized port.
 */
function normalizePort(val) {
  const port = parseInt(val, 10);

  if (isNaN(port)) {
    // named pipe
    return val;
  }

  if (port >= 0) {
    // port number
    return port;
  }

  return false;
}

/**
 * Event listener for HTTP server "error" event.
 * Provides user-friendly messages for common server startup errors.
 * @param {Error} error - The error object.
 */
function onError(error) {
  if (error.syscall !== 'listen') {
    throw error;
  }

  const bind = typeof port === 'string' ? 'Pipe ' + port : 'Port ' + port;

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case 'EACCES':
      console.error(bind + ' requires elevated privileges');
      process.exit(1);
      break;
    case 'EADDRINUSE':
      console.error(bind + ' is already in use');
      process.exit(1);
      break;
    default:
      throw error;
  }
}

/**
 * Event listener for HTTP server "listening" event.
 * Logs the address and port the server is listening on.
 */
function onListening() {
  const addr = server.address();
  const bind = typeof addr === 'string' ? 'pipe ' + addr : 'port ' + addr.port;
  debug('Listening on ' + bind); // Use debug for detailed logging
  console.log('Server is listening on ' + bind); // Console log for general visibility
}
