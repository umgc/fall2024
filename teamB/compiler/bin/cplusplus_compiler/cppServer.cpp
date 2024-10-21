#include <httplib.h>    // For HTTP server functionality
#include <iostream>     // For input/output operations
#include "CppCompiler.cpp"  // Include the C++ compiler logic

// Handles the POST request for compiling C++ files
void compileCppHandler(const httplib::Request &req, httplib::Response &res) {
    // Extract the contents of the 'testFile' and 'studentFile' from the form data
    std::string testFileContent = req.get_file_value("testFile").content;
    std::string studentFileContent = req.get_file_value("studentFile").content;

    // Write the test file content to /app/bin/test.cpp
    std::ofstream testFile("/app/bin/test.cpp");
    testFile << testFileContent;
    testFile.close();

    // Write the student file content to /app/bin/student.cpp
    std::ofstream studentFile("/app/bin/student.cpp");
    studentFile << studentFileContent;
    studentFile.close();

    // Call processCppRequest to compile and execute the C++ files, and get the result
    std::string result = processCppRequest("/app/bin/test.cpp", "/app/bin/student.cpp");

    // Set the result as the response content, specifying "text/plain" as the content type
    res.set_content(result, "text/plain");
}

int main() {
    httplib::Server svr;  // Create an instance of the httplib server

    // Define the POST endpoint /compile/cpp and associate it with compileCppHandler
    svr.Post("/compile/cpp", compileCppHandler);

    // Print a message to the console indicating that the server is running on port 8080
    std::cout << "Server listening on port 8080..." << std::endl;

    // Start the server, binding it to address 0.0.0.0 and port 8080
    svr.listen("0.0.0.0", 8080);

    return 0;
}