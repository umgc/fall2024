import 'package:flutter/material.dart';
import 'package:intelligrade/ui/assignment_form.dart';
import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/api/llm/openai_api.dart';

// List to store saved quizzes globally in memory for now
List<Map<String, dynamic>> savedQuizzes = [];

class GeneratedQuestionsPage extends StatefulWidget {
  final List<String> generatedQuestions;
  final String assignmentTitle; // Adding title for the assignment
  final String subject; // Adding subject for the assignment
  final String type; // Adding type for the assignment

  const GeneratedQuestionsPage({
    Key? key,
    required this.generatedQuestions,
    required this.assignmentTitle, // Required assignment title
    required this.subject, // Required assignment subject
    required this.type, 
  }) : super(key: key);

  @override
  _GeneratedQuestionsPageState createState() => _GeneratedQuestionsPageState();
}

class _GeneratedQuestionsPageState extends State<GeneratedQuestionsPage> {
  late List<String> _questions;
  bool _isLoading = false; // Add this for showing the loading spinner

  final OpenAiLLM _openAiLLM = OpenAiLLM('your-openai-api-key'); // Replace with your actual key

  @override
  void initState() {
    super.initState();
    // Filter out any empty or whitespace-only strings from the list of questions
    _questions = widget.generatedQuestions
        .map((question) => question.trim()) // Trim any leading/trailing whitespace
        .where((question) => question.isNotEmpty) // Only keep non-empty questions
        .toList();
  }

  // Function to regenerate a single question
  Future<void> _regenerateQuestion(int index) async {
    String regeneratedQuestion = await _openAiLLM.queryAI('Regenerate question');
    setState(() {
      _questions[index] = regeneratedQuestion; // Update the specific question
    });
  }

  // Function to regenerate all questions
  Future<void> _regenerateAllQuestions() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    List<String> regeneratedQuestions = [];
    for (var i = 0; i < _questions.length; i++) {
      String regeneratedQuestion = await _openAiLLM.queryAI('Regenerate question $i');
      regeneratedQuestions.add(regeneratedQuestion);
    }

    setState(() {
      _questions = regeneratedQuestions; // Replace with all regenerated questions
      _isLoading = false; // Hide loading indicator
    });
  }

  // Function to edit a specific question
  void _editQuestion(int index) {
    TextEditingController controller = TextEditingController(text: _questions[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Question'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Edit question'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _questions[index] = controller.text; // Save edited question
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close without saving
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to save the assignment
  void _saveAssignment() {
    final savedAssignment = {
      'title': widget.assignmentTitle,
      'subject': widget.subject,
      'type': widget.type,
      'numQuestions': _questions.length,
      'dateCreated': DateTime.now(),
      'status': 'Generated', // You can set different statuses like 'Draft', 'Published', etc.
      'questions': _questions,
    };

    // Add the saved assignment to the global list of saved quizzes
    savedQuizzes.add(savedAssignment);

    // Navigate to the Dashboard and pass the saved assignment
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoardPage(savedAssignments: savedQuizzes),
      ),
      (Route<dynamic> route) => false, // Clear the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const Header(), // Keep the header the same
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment Title: ${widget.assignmentTitle}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Subject: ${widget.subject}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Type: ${widget.type}',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Generated Questions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_questions[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editQuestion(index); // Edit question
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      _regenerateQuestion(index); // Regenerate single question
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _regenerateAllQuestions, // Regenerate all questions
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D6CE2),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            child: const Text('Regenerate All Questions'),
                          ),
                          ElevatedButton(
                            onPressed: _saveAssignment, // Save the assignment and navigate to the dashboard
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D6CE2),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            child: const Text('Submit Assignment'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(), // Loading spinner
            ),
        ],
      ),
    );
  }
}