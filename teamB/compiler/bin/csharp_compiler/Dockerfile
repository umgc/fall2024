# Use the official .NET SDK image as the base for building
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env
WORKDIR /app

# Copy the .csproj file
COPY CSharpServerApp.csproj ./

# Restore the dependencies
RUN dotnet restore

# Copy the rest of the application files
COPY . ./

# Build the project
RUN dotnet publish -c Release -o out

# Use the official .NET SDK image for running the app (not just the runtime)
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS final
WORKDIR /app

# Install curl and net-tools (which includes netstat)
RUN apt-get update && apt-get install -y curl net-tools

# Set the environment variable to force ASP.NET Core to listen on port 8001
ENV ASPNETCORE_URLS=http://+:8001

# Copy the built project from the build stage
COPY --from=build-env /app/out .

# Expose port 8001 to the outside world
EXPOSE 8001

# Run the application
ENTRYPOINT ["dotnet", "CSharpServerApp.dll"]