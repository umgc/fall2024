import 'openai_llm.dart';
import 'dart:io' show Platform;

void main() async {
  // Retrieve the OpenAI API key from an environment variable
  final openAiKey = Platform.environment['openAiKey='];
  
  if (openAiKey == null) {
    print('Please set the openAiKey= environment variable.');
    return;
  }

  final llmApi = LlmApi(openAiKey);
  
  try {
    final response = await llmApi.postToLlm('What is the capital of France?');
    print('Response from OpenAI:');
    print(response);
  } catch (e) {
    print('An error occurred: $e');
  }
}
