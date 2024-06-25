# Use the official Node.js image as the base image
FROM node:20-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Install bash and mysql-client
RUN apk update && apk add bash

# Expose the port the app runs on (default for Vite is 5173)
EXPOSE 5173

# Temporary entrypoint to keep the container running for debugging
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]