#include <zip.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <filesystem>
#include "cppFunctions.h"

namespace fs = std::filesystem;

/**
 * @brief Unzips a zip file into a specified directory using libzip.
 */
void unzipFile(const std::string& zipFilePath, const std::string& extractDir) {
    int error;
    zip* z = zip_open(zipFilePath.c_str(), ZIP_RDONLY, &error);

    if (!z) {
        char buf[1024];
        zip_error_to_str(buf, sizeof(buf), error, errno);
        std::cerr << "Error opening zip file: " << buf << std::endl;
        return;
    }

    zip_int64_t numEntries = zip_get_num_entries(z, 0);

    for (zip_uint64_t i = 0; i < numEntries; i++) {
        const char* name = zip_get_name(z, i, 0);
        if (!name) {
            std::cerr << "Error reading zip entry name: " << zip_strerror(z) << std::endl;
            continue;
        }

        std::string filePath = extractDir + "/" + name;

        if (name[strlen(name) - 1] == '/') {
            fs::create_directories(filePath);
            continue;
        }

        fs::create_directories(fs::path(filePath).parent_path());

        zip_file* zf = zip_fopen_index(z, i, 0);
        if (!zf) {
            std::cerr << "Error opening zip entry: " << zip_strerror(z) << std::endl;
            continue;
        }

        std::ofstream outFile(filePath, std::ios::binary);
        char buffer[4096];
        zip_int64_t bytesRead;
        while ((bytesRead = zip_fread(zf, buffer, sizeof(buffer))) > 0) {
            outFile.write(buffer, bytesRead);
        }

        zip_fclose(zf);
        outFile.close();
        std::cout << "Extracted: " << filePath << std::endl;
    }

    zip_close(z);
}

/**
 * @brief Compiles and runs both student submissions and master test files.
 *
 * This function compiles both the student submission and the master test file.
 * After execution, it captures the output and compares it with expected values.
 *
 * @param projectDir The directory where both the student files and test files are located.
 * @return A string representing the number of correct test cases and expected/actual outputs.
 */
std::string compileAndRun(const std::string& projectDir) {
    std::string executablePath = projectDir + "/output_executable";

    // Compile the C++ files (student submissions and test file)
    std::string compileCommand = "g++ " + projectDir + "/*.cpp -o " + executablePath;
    int compileStatus = system(compileCommand.c_str());
    if (compileStatus != 0) {
        return "Compilation failed!";
    }

    // Execute the compiled test file and capture output
    std::string command = executablePath + " > " + projectDir + "/test_output.txt";
    int runStatus = system(command.c_str());
    if (runStatus != 0) {
        return "Execution failed!";
    }

    // Read the test results
    std::ifstream outputFile(projectDir + "/test_output.txt");
    std::string output((std::istreambuf_iterator<char>(outputFile)), std::istreambuf_iterator<char>());

    // Return the test results (number of correct tests and expected vs actual output)
    return output;
}