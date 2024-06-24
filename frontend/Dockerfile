# Use the official Node.js image as the base image
FROM node:22.2.0-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Install bash and mysql-client
RUN apk update && apk add bash

# Expose the port the app runs on (default for Vite is 5173)
EXPOSE 5173

# Temporary entrypoint to keep the container running for debugging
CMD ["sh", "-c", "tail -f /dev/null"]