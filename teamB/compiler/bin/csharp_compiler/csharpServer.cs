/// <summary>
/// Entry point for the CSharpServerApp, which listens for HTTP requests to compile and execute C# code.
/// </summary>
namespace CSharpServerApp
{
    public class Program
    {
        /// <summary>
        /// Main method that starts the web server and listens for requests.
        /// </summary>
        /// <param name="args">Command-line arguments for the application.</param>
        public static void Main(string[] args)
        {
            // Create a new web application builder
            var builder = WebApplication.CreateBuilder(args);

            // Add controller services
            builder.Services.AddControllers();

            // Build the web application
            var app = builder.Build();

            // Map the POST request to the /compile/csharp endpoint
            app.MapPost("/compile/csharp", async (HttpContext context) =>
            {
                try
                {
                    Console.WriteLine("Received POST request at /compile/csharp");

                    // Initialize the CSharpCompiler to process the request
                    var compiler = new CSharpCompiler();
                    var response = await compiler.ProcessCSRequest(context.Request);
                    return Results.Content(response);
                }
                catch (Exception ex)
                {
                    // Log any exceptions and return an error response
                    Console.WriteLine("Error processing request: " + ex.Message);
                    return Results.Problem("Internal server error: " + ex.Message);
                }
            });

            // Run the web application on the specified URL
            app.Run("http://0.0.0.0:8001");
        }
    }
}