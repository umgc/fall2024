


//Assignment Generator
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  final apiService = ApiService(dotenv.env['PERPLEXITY_API_KEY'] ?? '');
  runApp(AssignmentApp(apiService: apiService));
}

class AssignmentApp extends StatelessWidget {
  final ApiService apiService;

  const AssignmentApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AssignmentGenerator(apiService: apiService),
    );
  }
}

class ApiService {
  final String baseUrl = 'https://api.perplexity.ai/chat/completions';
  final String apiKey;

  ApiService(this.apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('API key not found in .env file');
    }
  }

  Future<List<Assignment>> generateAssignments(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'mistral-7b-instruct',
          'messages': [
            {
              "role": "system",
              "content": """You are an educational assignment generator. 
              Create assignments in the following JSON format:
              [
                {
                  "name": "Assignment Title",
                  "question": "Question text",
                  "type": "multipleChoice",
                  "options": ["option1", "option2", "option3", "option4"],
                  "answer": "correct answer",
                  "subjectId": "subject1"
                }
              ]
              Types can be: multipleChoice, trueFalse, shortAnswer, essay, or code."""
            },
            {
              "role": "user",
              "content": "Generate an educational assignment based on this prompt: $prompt"
            }
          ],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      if (data['choices'] == null || data['choices'].isEmpty) {
        throw Exception('No choices in API response');
      }

      final content = data['choices'][0]['message']['content'];
      final jsonString = extractJsonFromContent(content);
      final assignmentsJson = jsonDecode(jsonString);

      if (assignmentsJson is! List) {
        throw Exception('Invalid response format: expected JSON array');
      }

      return List.generate(assignmentsJson.length, (i) {
        final json = assignmentsJson[i];
        json['name'] = 'Question ${i + 1}';
        json['answer'] = null;
        return Assignment.fromJson(json);
      });
    } catch (e) {
      throw Exception('Failed to generate assignments: $e');
    }
  }

  String extractJsonFromContent(String content) {
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = codeBlockRegex.firstMatch(content);
    return match != null ? match.group(1)!.trim() : content.trim();
  }
}

enum AssignmentType { multipleChoice, trueFalse, shortAnswer, essay, code }

class Assignment {
  final String name;
  final String question;
  final AssignmentType type;
  final List<String>? options;
  String? answer;
  final String? courseId;

  Assignment({
    required this.name,
    required this.question,
    required this.type,
    this.options,
    this.answer,
    this.courseId,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      name: json['name'] ?? 'Untitled Assignment',
      question: json['question'] ?? '',
      type: _parseAssignmentType(json['type']),
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      answer: json['answer'],
      courseId: json['courseId'],
    );
  }

  static AssignmentType _parseAssignmentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'multiplechoice':
        return AssignmentType.multipleChoice;
      case 'truefalse':
        return AssignmentType.trueFalse;
      case 'shortanswer':
        return AssignmentType.shortAnswer;
      case 'essay':
        return AssignmentType.essay;
      case 'code':
        return AssignmentType.code;
      default:
        return AssignmentType.shortAnswer;
    }
  }
}

class AssignmentGenerator extends StatefulWidget {
  final ApiService apiService;

  const AssignmentGenerator({super.key, required this.apiService});

  @override
  _AssignmentGeneratorState createState() => _AssignmentGeneratorState();
}

class _AssignmentGeneratorState extends State<AssignmentGenerator> {
  final TextEditingController _promptController = TextEditingController();
  final Map<int, TextEditingController> _answerControllers = {};
  List<Assignment> assignments = [];
  //int currentAssignmentIndex = 0;
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;
  int currentIndex = 0;
  String? selectedCourseId;
  bool assignmentsGenerated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Enter prompt for assignment generation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _generateAssignments,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Assignment', style:TextStyle (fontSize:18)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: assignments.isEmpty
                  ? const Center(child: Text('No assignments generated yet'))
                  : ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  _answerControllers.putIfAbsent(index, () => TextEditingController());
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(assignment.question),
                          const SizedBox(height: 8),
                          Text('Type: ${assignment.type.toString().split('.').last}'),
                          _buildAssignmentInput(assignment, index),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInput(Assignment assignment, int index) {
    switch (assignment.type) {
      case AssignmentType.multipleChoice:
        return Column(
          children: assignment.options?.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: assignment.answer,
              onChanged: (value) {
                setState(() {
                  assignment.answer = value;
                });
              },
            );
          }).toList() ?? [],
        );
      case AssignmentType.trueFalse:
        return Column(
          children: ['True', 'False'].map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: assignment.answer,
              onChanged: (value) {
                setState(() {
                  assignment.answer = value;
                });
              },
            );
          }).toList(),
        );
      case AssignmentType.shortAnswer:

      case AssignmentType.essay:
        return TextField(
          controller: _answerControllers[index],
          maxLines: assignment.type == AssignmentType.essay ? null : 3,
          minLines: assignment.type == AssignmentType.essay ? 10 : 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter your ${assignment.type == AssignmentType.essay ? 'essay' : 'answer'}...',
          ),
          onChanged: (value) {
            assignment.answer = value;
          },
        );
      case AssignmentType.code:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _answerControllers[index],
            maxLines: null,
            minLines: 10,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Write your code...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value) {
              assignment.answer = value;
            },
          ),
        );
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: currentIndex > 0 ? () => setState(() => currentIndex--) : null,
          child: const Text('Previous',style:TextStyle (fontSize:18)),
        ),
        ElevatedButton(
          onPressed: currentIndex < assignments.length - 1 ? () => setState(() => currentIndex++) : null,
          child: const Text('Next', style:TextStyle (fontSize:18)),
        ),
        ElevatedButton(
          onPressed: assignments.isNotEmpty && !isUploading ? _uploadToMoodle : null,
          child: isUploading ? const CircularProgressIndicator() : const Text('Upload to Moodle',style:TextStyle (fontSize:18)),
        ),
        ElevatedButton(
          onPressed: _cancelAssignments,
          child: const Text('Cancel', style:TextStyle (fontSize:18)),
        ),
      ],
    );
  }

  void _cancelAssignments() {
    setState(() {
      _promptController.clear();
      assignments.clear();
      _answerControllers.clear();
      currentIndex = 0;
      errorMessage = null;
      assignmentsGenerated = false;
    });
  }

  Future<void> _generateAssignments() async {
    setState(() {
      //assignments.add("New Assignment ${assignments.length + 1}" as Assignment);
      isLoading = true;
      errorMessage = null;
    });

    try {
      final generatedAssignments = await widget.apiService.generateAssignments(_promptController.text);
      setState(() {
        assignments = generatedAssignments;
        assignmentsGenerated = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error generating assignments: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _uploadToMoodle() async {
    if (selectedCourseId == null) {
      setState(() {
        errorMessage = 'Please select a course';
      });
      return;
    }

    setState(() {
      isUploading = true;
      errorMessage = null;
    });

    try {
      // Implement Moodle upload logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulating upload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All assignments uploaded to Moodle successfully')),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error uploading assignments to Moodle: $e';
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }
}







