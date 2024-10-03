using Microsoft.AspNetCore.Builder;  // For building the ASP.NET Core application
using Microsoft.AspNetCore.Hosting;  // For configuring the web hosting environment
using Microsoft.Extensions.Hosting;  // For hosting utilities like creating a web server
using Microsoft.Extensions.DependencyInjection;  // For adding services like controllers

// Create a new web application builder instance
var builder = WebApplication.CreateBuilder(args);

// Add controller services to the application (optional, but required if you have controllers)
builder.Services.AddControllers();

// Build the application
var app = builder.Build();

// Define a POST endpoint at /compile/csharp that processes C# compilation requests
app.MapPost("/compile/csharp", async (HttpContext context) =>
{
    var compiler = new CSharpCompiler();  // Create an instance of the CSharpCompiler class
    var response = await compiler.ProcessCSRequest(context.Request);  // Process the incoming request with the compiler
    return Results.Content(response);  // Return the compiler's response as plain text
});

// Run the application (start listening for requests)
app.Run();