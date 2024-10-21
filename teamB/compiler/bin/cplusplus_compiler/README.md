A C++ server app built using the httplib library, configured to run with Docker. This code handles HTTP POST requests to /compile/cpp and processes C++ code submissions for compilation and execution.

You can run the code locally like this:
- g++ -o server CppServer.cpp -lhttplib.
- ./server.

After the server starts, you can test it from a second terminal using curl to POST a C++ file as so:
- curl -X POST -F "studentFile=@StudentSubmission.cpp" -F "testFile=@UnitTest.cpp" http://localhost:8080/compile/cpp

This request will send the C++ test file (UnitTest.cpp) and the student submission (StudentSubmission.cpp) to the server for compilation and testing.

You can build and run the server using Docker as so:
- docker build -t cpp-server .
- docker run -it -p 8080:8080 cpp-server

In another terminal, you can send POST requests to the running container as before:
- curl -X POST -F "studentFile=@StudentSubmission.cpp" -F "testFile=@UnitTest.cpp" http://localhost:8080/compile/cpp

This will compile and execute the C++ files inside the container.

When running the C++ server, you should see output similar to the following:
Server listening on port 8080...
Processing student submission...
Compilation completed.
Test results: ...