import 'package:flutter/material.dart';
import 'package:intelligrade/ui/assignment_form.dart';
import 'package:intelligrade/ui/dashboard_page.dart';
import 'package:intelligrade/api/llm/openai_api.dart';


class GeneratedQuestionsPage extends StatefulWidget {
  final List<String> generatedQuestions;

  const GeneratedQuestionsPage({super.key, required this.generatedQuestions});

  @override
  // ignore: library_private_types_in_public_api
  _GeneratedQuestionsPageState createState() => _GeneratedQuestionsPageState();
}

class _GeneratedQuestionsPageState extends State<GeneratedQuestionsPage> {
  late List<String> _questions;
  final OpenAiLLM _openAiLLM = OpenAiLLM('your-openai-api-key');

  @override
  void initState() {
    super.initState();
    _questions = List.from(widget.generatedQuestions); // Copy initial questions
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
    List<String> regeneratedQuestions = [];
    for (var i = 0; i < _questions.length; i++) {
      String regeneratedQuestion = await _openAiLLM.queryAI('Regenerate question $i');
      regeneratedQuestions.add(regeneratedQuestion);
    }
    setState(() {
      _questions = regeneratedQuestions; // Replace with all regenerated questions
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(), // Keep the header the same
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        onPressed: () {
                          // Implement logic to submit the questions to the next page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7D6CE2),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: const Text('Submit Questions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
