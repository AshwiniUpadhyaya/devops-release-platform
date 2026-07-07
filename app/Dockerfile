# Base image: official Node.js, slim version for smaller size
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package files first (for caching — explained below)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Document which port the app listens on
EXPOSE 3000

# Command to run when the container starts
CMD ["node", "server.js"]
