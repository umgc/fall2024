import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intelligrade/api/llm/llm_api.dart';
import 'package:intelligrade/api/moodle/moodle_api_singleton.dart';
import 'package:intelligrade/controller/model/essay_grader.dart';
import '/controller/model/beans.dart';

class AssignmentSubmissionsPage extends StatelessWidget {
  final int assignmentID;
  final String assignmentTitle;
  final List<Submission> studentSubmissions;

  AssignmentSubmissionsPage(
      this.assignmentID, this.assignmentTitle, this.studentSubmissions);

  //Function to query Perplexity to generate a rubric
  Future<dynamic> gradeRubricFromAi(String inputs) async {
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

  Future<MoodleRubric?> getAssignmentRubric() async {
    var rubric = await MoodleApiSingleton().getRubric(assignmentID.toString());
    return rubric;
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
                          getAssignmentRubric().then((var results) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EssayGrader('''{
  "id": 38,
  "rubric_criteria": [
    {
      "id": 96,
      "description": "Understanding of Story Themes",
      "levels": [
        {
          "id": 386,
          "score": 0,
          "definition": "Fails to identify any themes in the story.",
          "chosen": false
        },
        {
          "id": 387,
          "score": 1,
          "definition": "Identifies one theme but does not provide adequate analysis or examples.",
          "chosen": false
        },
        {
          "id": 388,
          "score": 2,
          "definition": "Identifies two themes and provides some analysis and examples, but the depth is limited.",
          "chosen": false
        },
        {
          "id": 389,
          "score": 3,
          "definition": "Identifies multiple themes and provides thorough analysis and relevant examples.",
          "chosen": true
        }
      ],
      "remarks": "The submission identifies several key themes such as friendship, loyalty, life cycles, and perseverance, providing relevant examples from the story."
    },
    {
      "id": 97,
      "description": "Analysis and Interpretation",
      "levels": [
        {
          "id": 390,
          "score": 0,
          "definition": "Lacks any meaningful analysis or interpretation of the themes.",
          "chosen": false
        },
        {
          "id": 391,
          "score": 1,
          "definition": "Provides basic analysis but lacks depth and insight into the themes.",
          "chosen": false
        },
        {
          "id": 392,
          "score": 2,
          "definition": "Offers some insightful analysis but could be more detailed and supported.",
          "chosen": true
        },
        {
          "id": 393,
          "score": 3,
          "definition": "Provides comprehensive and insightful analysis of the themes with strong evidence from the text.",
          "chosen": false
        }
      ],
      "remarks": "The analysis provides insightful connections but lacks full depth and a comprehensive interpretation of the themes."
    },
    {
      "id": 98,
      "description": "Use of Examples and Evidence",
      "levels": [
        {
          "id": 394,
          "score": 0,
          "definition": "Does not use any examples or evidence from the text to support the analysis.",
          "chosen": false
        },
        {
          "id": 395,
          "score": 1,
          "definition": "Uses a few examples but they are not well-integrated or relevant to the analysis.",
          "chosen": false
        },
        {
          "id": 396,
          "score": 2,
          "definition": "Uses several relevant examples but could be more effectively integrated into the analysis.",
          "chosen": true
        },
        {
          "id": 397,
          "score": 3,
          "definition": "Effectively uses multiple relevant examples from the text to strongly support the analysis.",
          "chosen": false
        }
      ],
      "remarks": "The examples provided are relevant but could be more deeply integrated into the overall analysis."
    },
    {
      "id": 99,
      "description": "Writing Quality and Clarity",
      "levels": [
        {
          "id": 398,
          "score": 0,
          "definition": "Writing is unclear, disorganized, and lacks coherence.",
          "chosen": false
        },
        {
          "id": 399,
          "score": 1,
          "definition": "Writing is somewhat clear but lacks organization and coherence in places.",
          "chosen": false
        },
        {
          "id": 400,
          "score": 2,
          "definition": "Writing is generally clear and organized but may have some minor issues with coherence.",
          "chosen": true
        },
        {
          "id": 401,
          "score": 3,
          "definition": "Writing is clear, well-organized, and coherent throughout.",
          "chosen": false
        }
      ],
      "remarks": "The writing is clear and organized but has minor issues with flow and coherence in some areas."
    }
  ]
}
'''),
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