using System;
using System.Diagnostics;  // For working with system processes
using System.IO;  // For file handling
using System.Threading.Tasks;  // For async/await functionality
using Microsoft.AspNetCore.Http;  // For handling HTTP requests

// Class to handle the compilation and execution of C# code
public class CSharpCompiler
{
    // Processes an HTTP request containing C# files and returns the result of the compilation and execution
    public async Task<string> ProcessCSRequest(HttpRequest req)
    {
        var uploadedFiles = new List<IFormFile>();  // List to hold uploaded files
        string unitTestFilePath = string.Empty;  // Path for the test file
        string submissionFilePath = string.Empty;  // Path for the student's submission
        var uploadDir = Path.Combine(Directory.GetCurrentDirectory(), "uploads_cs");  // Directory to store uploaded files

        // Create the upload directory if it doesn't exist
        if (!Directory.Exists(uploadDir))
            Directory.CreateDirectory(uploadDir);

        // Loop through the uploaded files and save them to the correct paths
        foreach (var formFile in req.Form.Files)
        {
            if (formFile.FileName.EndsWith("_test.cs"))  // Check if the file is a test file
            {
                unitTestFilePath = Path.Combine(uploadDir, formFile.FileName);  // Set path for the test file
            }
            else  // Otherwise, assume it's the student's submission file
            {
                submissionFilePath = Path.Combine(uploadDir, formFile.FileName);  // Set path for the submission file
            }

            // Save the uploaded test file to disk
            using (var stream = new FileStream(unitTestFilePath, FileMode.Create))
            {
                await formFile.CopyToAsync(stream);  // Asynchronously copy the file data to the path
            }
        }

        // Check if both test and submission files have been uploaded
        if (string.IsNullOrEmpty(unitTestFilePath) || string.IsNullOrEmpty(submissionFilePath))
        {
            return "Missing test or submission file!";  // Return error if either file is missing
        }

        // Run the test and return the result
        var result = await RunTest(unitTestFilePath, submissionFilePath);
        return result;
    }

    // Runs the C# test by compiling the test and submission files, then executing the result
    private async Task<string> RunTest(string testFilePath, string submissionFilePath)
    {
        // Path to store the compiled executable
        string compiledOutputPath = Path.Combine(Directory.GetCurrentDirectory(), "uploads_cs", "submission.exe");

        // Create a process to compile the test and submission files
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "csc",  // Use the C# compiler (csc)
                Arguments = $"-out:{compiledOutputPath} {testFilePath} {submissionFilePath}",  // Compile the files into an executable
                RedirectStandardOutput = true,  // Capture standard output
                RedirectStandardError = true,  // Capture standard error
                UseShellExecute = false,  // Don't use the shell to execute the process
                CreateNoWindow = true  // Don't create a window for the process
            }
        };

        // Start the compilation process
        process.Start();
        var result = await process.StandardOutput.ReadToEndAsync();  // Read the compilation output
        var errors = await process.StandardError.ReadToEndAsync();  // Read any compilation errors
        process.WaitForExit();  // Wait for the process to finish

        // If there are compilation errors, return them
        if (!string.IsNullOrEmpty(errors))
        {
            return $"Compilation errors: {errors}";
        }

        // Create a process to run the compiled executable
        process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = compiledOutputPath,  // Path to the compiled executable
                RedirectStandardOutput = true,  // Capture the output of the program
                RedirectStandardError = true,  // Capture any runtime errors
                UseShellExecute = false,  // Don't use the shell to execute the process
                CreateNoWindow = true  // Don't create a window for the process
            }
        };

        // Start the execution process
        process.Start();
        result = await process.StandardOutput.ReadToEndAsync();  // Read the program's output
        errors = await process.StandardError.ReadToEndAsync();  // Read any runtime errors
        process.WaitForExit();  // Wait for the process to finish

        // Return the result if there are no errors, otherwise return the errors
        return string.IsNullOrEmpty(errors) ? result : errors;
    }
}