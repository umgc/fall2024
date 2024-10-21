A C# server app built using ASP.NET Core, configured to run with Docker. This code handles HTTP POST requests to /compile/csharp and processes C# code submissions for compilation and execution.

You can run the code with the .NET SDK like this:
- dotnet restore
- dotnet run --project CSharpServer.csproj

After the server starts, you can test it from a second terminal using curl to POST a C# file as so:
- curl -X POST -F "studentFile=@StudentSubmission.cs" -F "testFile=@UnitTest.cs" http://localhost:5000/compile/csharp

This request will send the C# test file (UnitTest.cs) and the student submission (StudentSubmission.cs) to the server for compilation and testing.

You can build and run the server using Docker as so:
- docker build -t csharp-server .
- docker run -it -p 5000:5000 csharp-server

In another terminal, you can send POST requests to the running container as before:
- curl -X POST -F "studentFile=@StudentSubmission.cs" -F "testFile=@UnitTest.cs" http://localhost:5000/compile/csharp

This will compile and execute the C# files inside the container.

When running the C# server, you should see output similar to the following:
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5000
Processing student submission...
Compilation completed.
Test results: ...