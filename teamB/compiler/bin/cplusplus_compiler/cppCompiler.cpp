#include <array>    // For std::array, used for storing command output
#include <cstdio>   // For FILE, popen, pclose
#include <iostream> // For std::string, std::cout
#include <fstream>  // For file handling (not currently used in this snippet)
#include <cstdlib>  // For system-related functions like popen
#include <vector>   // For std::vector (not used in this snippet)
#include <string>   // For std::string, handling text

#ifdef _WIN32
    // Use _popen and _pclose for Windows compatibility
    #define popen _popen
    #define pclose _pclose
#endif

// Runs a system command and returns its output as a string
std::string runCommand(const std::string &command) {
    std::string result;
    std::array<char, 128> buffer; // Buffer to store command output
    FILE *pipe = popen(command.c_str(), "r"); // Execute command and open pipe for reading output
    if (!pipe) return "popen failed!"; // Return an error if popen fails

    // Read output from the command into the result string
    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
        result += buffer.data(); // Append command output to result
    }
    pclose(pipe); // Close the pipe after command execution
    return result; // Return the collected output
}

// Compiles two C++ files (test and student) and executes the compiled program
std::string processCppRequest(const std::string &testFilePath, const std::string &studentFilePath) {
    // Command to compile the test file and student file into an executable
    std::string compileCommand = "g++ " + testFilePath + " " + studentFilePath + " -o /app/bin/program";
    
    // Run the compile command and capture the output (if any)
    std::string compileResult = runCommand(compileCommand);

    // If there's output from the compile command, it likely indicates a compilation error
    if (!compileResult.empty()) {
        return "Compilation Error: " + compileResult;
    }

    // If compilation is successful, execute the compiled program and return its output
    std::string executionResult = runCommand("/app/bin/program");
    return executionResult; // Return the output of the executed program
}