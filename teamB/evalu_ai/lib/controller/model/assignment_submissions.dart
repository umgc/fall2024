import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intelligrade/api/llm/llm_api.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';

class AssignmentSubmissionsPage extends StatelessWidget {
  final String assignmentTitle;
  final List<String> studentNames;
  final List<String> studentSubmissions;

  AssignmentSubmissionsPage({
    required this.assignmentTitle,
    required this.studentNames,
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

  Future<List<String>> getParticipantNames() async {
    var participants = await MoodleApiSingleton().getCourseParticipants('2');
    List<String> names = [];
    for (var p in participants) {
      names.add(p.fullname);
    }
    return names;
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
                itemCount: studentNames.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(studentNames[index]), // Student name as title
                      //subtitle: Text('subtitle'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          getParticipantNames().then((var results) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignmentSubmissionsPage(
                                  studentNames: results,
                                  assignmentTitle: 'myEssay',
                                  studentSubmissions: [
                                    '1',
                                    '22'
                                  ], // Handle actual submissions
                                ),
                              ),
                            );
                          });
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

/*
Future<void> main() async {
  
  runApp(MaterialApp(
    home: AssignmentSubmissionsPage(
      assignmentTitle: 'History Essay Assignment',
      studentSubmissions: [],
    ),
  ));
}
*/