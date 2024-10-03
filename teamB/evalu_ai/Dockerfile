# Use the official Flutter image as the base image
FROM google/flutter:latest

# Copy the Flutter project files into the container
COPY . /app/

# Set the working directory
WORKDIR /app

# Get the required packages
RUN flutter pub get

# Build the Flutter app for web
RUN flutter build web

# Use a lightweight web server to serve the built app
FROM nginx:alpine

# Copy the built web app from the previous stage
COPY --from=0 /app/build/web /usr/share/nginx/html

# Expose the port on which the Nginx web server is listening
EXPOSE 80