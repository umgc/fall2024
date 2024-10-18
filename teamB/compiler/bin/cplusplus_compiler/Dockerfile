# Use an official image for C++ development
FROM ubuntu:20.04

# Set environment variable to skip interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    unzip \
    zip \
    libzip-dev \
    libssl-dev \
    g++ \
    wget \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Download httplib.h (cpp-httplib) from GitHub
RUN curl -L https://github.com/yhirose/cpp-httplib/raw/master/httplib.h -o /usr/local/include/httplib.h

# Set the working directory
WORKDIR /app

# Copy the entire source code into the container
COPY . /app

# Compile the application with C++17 support
RUN g++ cppServer.cpp cppCompiler.cpp -o cppServerApp -lzip -lpthread -std=c++17

# Expose port 8000 for the server
EXPOSE 8000

# Run the server
CMD ["./cppServerApp"]