# Use an official gcc image
FROM gcc:latest

# Set the working directory
WORKDIR /app

# Install HTTP library
RUN apt-get update && apt-get install -y libhttplib-dev

# Copy the source files
COPY . .

# Compile the server
RUN g++ -o server CppServer.cpp -lhttplib

# Expose the port
EXPOSE 8080

# Run the server
CMD ["/app/server"]