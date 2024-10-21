#include "httplib.h"
#include <iostream>
#include <fstream>
#include <string>
#include <filesystem>
#include "cppFunctions.h"

using namespace std;
namespace fs = std::filesystem;

int main() {
    httplib::Server svr;

    svr.Post("/compile/cpp", [&](const httplib::Request& req, httplib::Response& res) {
        // Ensure that the request is multipart/form-data
        if (!req.is_multipart_form_data()) {
            res.status = 400;
            res.set_content("Invalid form data.", "text/plain");
            return;
        }

        string uploadDir = "uploads_cpp";
        if (fs::exists(uploadDir)) {
            fs::remove_all(uploadDir);
        }
        fs::create_directory(uploadDir);

        string mainTestFilePath;
        vector<string> submissionFiles;
        vector<string> zipFiles;

        // Iterate through uploaded files
        for (const auto& file : req.files) {
            const auto& fileName = file.second.filename;
            const auto& fileContent = file.second.content;
            string filePath = uploadDir + "/" + fileName;

            ofstream outFile(filePath, ios::binary);
            outFile.write(fileContent.data(), fileContent.size());
            outFile.close();

            if (fileName.find(".zip") != string::npos) {
                zipFiles.push_back(filePath);
            }
            else {
                submissionFiles.push_back(filePath);
            }
        }

        string unzipDir = uploadDir + "/unzipped";
        fs::create_directory(unzipDir);

        for (const string& zipFile : zipFiles) {
            unzipFile(zipFile, unzipDir);
        }

        // Check all files and locate _main.cpp (the master test file)
        for (const auto& entry : fs::directory_iterator(unzipDir)) {
            const string filePath = entry.path().string();
            if (filePath.find("_main.cpp") != string::npos) {
                mainTestFilePath = filePath;
            }
            else {
                submissionFiles.push_back(filePath);
            }
        }

        // Ensure a main test file is present
        if (mainTestFilePath.empty()) {
            res.status = 400;
            res.set_content("Main test file (_main.cpp) missing.", "text/plain");
            return;
        }

        // Compile and run the files using cppCompiler.cpp
        string result = compileAndRun(unzipDir);

        // Return the test results (number of correct tests and expected vs actual output)
        res.set_content(result, "text/plain");
        });

    cout << "Server listening on port 8000..." << endl;
    svr.listen("0.0.0.0", 8000);
}