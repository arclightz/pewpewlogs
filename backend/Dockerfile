# Use the official Node.js image as the base image
FROM node:22.2.0-alpine

# Create and change to the app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install bash and mysql-client
RUN apk update && apk add bash mysql-client

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Define the command to run the application
CMD ["npm", "run", "dev"]