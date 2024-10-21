# Use an official OpenJDK runtime as a parent image
FROM openjdk:11-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Maven for building Java projects
RUN apt-get update && apt-get install -y maven

# Install dependencies and compile the Java application
RUN mvn clean package

# Make port 8002 available to the world outside this container
EXPOSE 8002

# Run the Spring Boot application
CMD ["java", "-jar", "target/java-server-app-1.0-SNAPSHOT.jar"]