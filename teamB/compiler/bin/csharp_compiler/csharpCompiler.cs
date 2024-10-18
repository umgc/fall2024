using System.Diagnostics;
using System.IO.Compression;

namespace CSharpServerApp
{
    public class CSharpCompiler
    {
        /// <summary>
        /// Processes the incoming HTTP request containing C# files, unzips them if necessary,
        /// identifies the main test file and the student submission files, and then compiles and runs them.
        /// </summary>
        /// <param name="req">The HTTP request containing the uploaded files.</param>
        /// <returns>A string containing the test results or error messages.</returns>
        public async Task<string> ProcessCSRequest(HttpRequest req)
        {
            Console.WriteLine("Received request to compile C# files.");

            // Create the upload directory path
            var uploadDir = Path.Combine(Directory.GetCurrentDirectory(), "uploads_cs");

            // Clean up any previous uploads by deleting the directory if it exists
            if (Directory.Exists(uploadDir))
            {
                Directory.Delete(uploadDir, true);
            }

            // Create a new upload directory
            Directory.CreateDirectory(uploadDir);
            Console.WriteLine("Created uploads directory.");

            string mainTestFilePath = null;
            List<string> submissionFilePaths = new List<string>();

            // Iterate through the uploaded files
            foreach (var formFile in req.Form.Files)
            {
                Console.WriteLine($"Received file: {formFile.FileName}");

                // Check if the file is a zip file
                if (formFile.FileName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
                {
                    // Save the zip file to the uploads directory
                    var zipFilePath = Path.Combine(uploadDir, formFile.FileName);
                    using (var stream = new FileStream(zipFilePath, FileMode.Create))
                    {
                        await formFile.CopyToAsync(stream);
                    }

                    Console.WriteLine($"Saved zip file to {zipFilePath}");
                    // Extract the zip file contents to the uploads directory
                    ZipFile.ExtractToDirectory(zipFilePath, uploadDir);
                    Console.WriteLine("Zip file extracted.");

                    // Iterate through the extracted files
                    var extractedFiles = Directory.GetFiles(uploadDir);
                    foreach (var file in extractedFiles)
                    {
                        Console.WriteLine($"Processing extracted file: {file}");

                        // Check if the file is the main test file (_main.cs)
                        if (file.Contains("_main.cs", StringComparison.OrdinalIgnoreCase))
                        {
                            mainTestFilePath = file;
                        }
                        else
                        {
                            // If not, it's a submission file
                            submissionFilePaths.Add(file);
                        }
                    }
                }
                else
                {
                    // Handle non-zip file uploads
                    var filePath = Path.Combine(uploadDir, formFile.FileName);

                    // Check if the file is the main test file (_main.cs)
                    if (formFile.FileName.Contains("_main.cs", StringComparison.OrdinalIgnoreCase))
                    {
                        mainTestFilePath = filePath;
                    }
                    else
                    {
                        // Otherwise, it's a submission file
                        submissionFilePaths.Add(filePath);
                    }

                    // Save the file to the uploads directory
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await formFile.CopyToAsync(stream);
                    }

                    Console.WriteLine($"Saved file to {filePath}");
                }
            }

            // Ensure the main test file (_main.cs) is present
            if (string.IsNullOrEmpty(mainTestFilePath))
            {
                return "Error: Main test file (_main.cs) is missing.";
            }

            // Ensure there are submission files present
            if (submissionFilePaths.Count == 0)
            {
                return "Error: No submission files found.";
            }

            // Run the test and return the results
            return await RunTest(uploadDir);
        }

        /// <summary>
        /// Compiles the project containing both the student submission files and the main test file, runs it, and returns the results.
        /// </summary>
        /// <param name="projectDir">The directory containing the project files.</param>
        /// <returns>A string containing the compilation and test results.</returns>
        private async Task<string> RunTest(string projectDir)
        {
            Console.WriteLine("Starting compilation...");

            string csprojPath = Path.Combine(projectDir, "TempProject.csproj");

            var csprojContent = @"
            <Project Sdk=""Microsoft.NET.Sdk"">
            <PropertyGroup>
                <OutputType>Exe</OutputType>
                <TargetFramework>net6.0</TargetFramework>
            </PropertyGroup>
            </Project>
            ";

            await File.WriteAllTextAsync(csprojPath, csprojContent);
            Console.WriteLine("Created project file at: " + csprojPath);

            // Restore NuGet packages
            var restoreProcess = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "dotnet",
                    Arguments = "restore " + csprojPath,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WorkingDirectory = projectDir
                }
            };

            restoreProcess.Start();
            var restoreErrors = await restoreProcess.StandardError.ReadToEndAsync();
            restoreProcess.WaitForExit();

            if (!string.IsNullOrEmpty(restoreErrors))
            {
                return $"Restore errors: {restoreErrors}";
            }

            var buildProcess = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "dotnet",
                    Arguments = "build --no-restore",
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WorkingDirectory = projectDir
                }
            };

            buildProcess.Start();
            var buildErrors = await buildProcess.StandardError.ReadToEndAsync();
            buildProcess.WaitForExit();

            if (!string.IsNullOrEmpty(buildErrors))
            {
                return $"Build errors: {buildErrors}";
            }

            // Run the compiled project
            var runProcess = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "dotnet",
                    Arguments = "run --project " + csprojPath,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WorkingDirectory = projectDir
                }
            };

            runProcess.Start();
            var result = await runProcess.StandardOutput.ReadToEndAsync();
            var runErrors = await runProcess.StandardError.ReadToEndAsync();
            runProcess.WaitForExit();

            if (!string.IsNullOrEmpty(runErrors))
            {
                return $"Errors: {runErrors}";
            }

            return result;
        }
    }
}