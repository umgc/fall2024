import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGPTService {
  // Store the API key securely (ideally load from environment variables)
  final String apiKey =''; // Replace with your actual key

  Future<String> getChatResponse(String prompt) async {
    // Update the endpoint to use the correct chat completion endpoint
    var url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Set headers, including API key
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // Create the request body using the correct format for the chat models
    var body = jsonEncode({
      'model': 'gpt-3.5-turbo', // Use a chat model like 'gpt-3.5-turbo'
      'messages': [
        {
          'role': 'user', // The user's input
          'content': prompt // The message input by the user
        }
      ],
      'max_tokens': 100, // Max tokens for response
      'temperature': 0.7, // Controls the randomness in the response
    });

    try {
      // Make the POST request to the chat completions endpoint
      var response = await http.post(url, headers: headers, body: body);

      // Check for successful response
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']
            .trim(); // Return the chat response
      } else {
        // Log the error response and handle failure cases
        print('Failed to fetch response. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return 'Sorry, I couldn’t fetch a response. Please try again.';
      }
    } catch (error) {
      // Log and handle connection or parsing errors
      print('Error occurred: $error');
      return 'An error occurred. Please check your internet connection and try again.';
    }
  }
}
