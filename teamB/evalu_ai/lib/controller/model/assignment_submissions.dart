import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intelligrade/api/llm/llm_api.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import '/controller/model/beans.dart';

class AssignmentSubmissionsPage extends StatelessWidget {
  final int assignmentID;
  final String assignmentTitle;
  final List<Submission> studentSubmissions;

  AssignmentSubmissionsPage(
      this.assignmentID, this.assignmentTitle, this.studentSubmissions);

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

  Future<List<Submission>> getParticipantSubmissions() async {
    var submissions =
        await MoodleApiSingleton().getAssignmentSubmissions(assignmentID);
    List<Submission> subs = [];
    for (var s in submissions) {
      subs.add(s);
    }
    return subs;
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
                itemCount: studentSubmissions.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(studentSubmissions[index].userid.toString() +
                          ' is student ID'), // Student name as title
                      //subtitle: Text('subtitle'),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          getParticipantSubmissions().then((var results) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignmentSubmissionsPage(
                                    55, "My Assignment", results),
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