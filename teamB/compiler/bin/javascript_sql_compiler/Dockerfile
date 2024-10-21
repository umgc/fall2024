# Use the official Node.js image as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install the application dependencies
RUN npm install

# Update package list and install Python3 and pip (Python package manager) 
RUN apt-get update && apt-get install -y \
    python3 \
    oython-pip

# Copy the rest of the application code to the container
COPY . .

# Build the application
RUN npm run build

# Expose the port that the application will run on
EXPOSE 3000

# Set environment variable
ENV COMPILER_KEY="evaluAIteamB"

# Set the command to start the application
CMD ["npm", "start"]
