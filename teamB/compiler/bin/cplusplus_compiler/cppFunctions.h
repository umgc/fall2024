#ifndef CPPFUNCTIONS_H
#define CPPFUNCTIONS_H

#include <string>

// Function declarations (not definitions)
void unzipFile(const std::string& zipFilePath, const std::string& extractDir);
std::string compileAndRun(const std::string& projectDir);

#endif