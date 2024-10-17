import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intelligrade/api/llm/llm_api.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';

class AssignmentSubmissionsPage extends StatelessWidget {
  final String assignmentTitle;
  final List<String> studentSubmissions;

  AssignmentSubmissionsPage({
    required this.assignmentTitle,
    required this.studentSubmissions,
  });

  //Function to query Perplexity to generate a rubric
  Future<dynamic> genRubricFromAi(String inputs) async {
    String apiKey = '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';
    LlmApi myLLM = LlmApi(apiKey);
    String queryPrompt = '''

$inputs
''';
    String rubric = await myLLM.postToLlm(queryPrompt);
    return jsonDecode(rubric);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment Submissions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Title
            Text(
              assignmentTitle,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0), // Spacing between title and submissions

            // Student Submissions List
            Expanded(
              child: ListView.builder(
                itemCount: studentSubmissions.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text('Student Submission ${index + 1}'),
                      subtitle: Text(studentSubmissions[index]),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          // Handle grade button press, e.g., navigate to grading page
                          var api = MoodleApiSingleton();
                          //var result = await api.getRubric();
                          //print();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Grade button pressed')),
                          );
                        },
                        child: Text('Grade'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AssignmentSubmissionsPage(
      assignmentTitle: 'History Essay Assignment',
      studentSubmissions: [
        'John Doe - Submitted',
        'Jane Smith - Submitted',
        'Alice Johnson - Pending',
        'Bob Williams - Submitted',
      ],
    ),
  ));
}
