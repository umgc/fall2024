import 'package:flutter/material.dart';
import '../Api/moodle_api_singleton.dart';
import '../Controller/beans.dart';
import 'view_submission_detail.dart';
import '../Api/llm_api.dart';
import 'dart:convert';

class SubmissionList extends StatefulWidget {
  final int assignmentId;
  final String courseId;

  SubmissionList({
    required this.assignmentId,
    required this.courseId,
  });

  @override
  SubmissionListState createState() => SubmissionListState();
}

class SubmissionListState extends State<SubmissionList> {
  MoodleApiSingleton api = MoodleApiSingleton();
  bool isLoading = false;

  late Future<List<SubmissionWithGrade>> futureSubmissionsWithGrades =
      api.getSubmissionsWithGrades(widget.assignmentId);
  late Future<List<Participant>> futureParticipants =
      api.getCourseParticipants(widget.courseId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("View Submissions"),
        actions: [
          // IconButton(
          //   icon: Icon(
          //     Icons.edit, // Icon for Edit Questions button
          //     color: Theme.of(context).colorScheme.onPrimaryContainer,
          //   ),
                          
          //       onPressed: () {
          //         Navigator.of(context).push(MaterialPageRoute(
          //             builder: (context) => RubricScreen()));
          //       },
                
          //     ),
        ],
      ),
      body: FutureBuilder<List<Participant>>(
        future: futureParticipants,
        builder: (BuildContext context,
            AsyncSnapshot<List<Participant>> participantSnapshot) {
          if (participantSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (participantSnapshot.hasError) {
            return Center(child: Text('Error: ${participantSnapshot.error}'));
          } else if (!participantSnapshot.hasData ||
              participantSnapshot.data!.isEmpty) {
            return Center(child: Text('No participants found.'));
          } else {
            return FutureBuilder<List<SubmissionWithGrade>>(
              future: futureSubmissionsWithGrades,
              builder: (BuildContext context,
                  AsyncSnapshot<List<SubmissionWithGrade>> submissionSnapshot) {
                if (submissionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (submissionSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${submissionSnapshot.error}'));
                } else {
                  List<Participant> participants = participantSnapshot.data!;
                  List<SubmissionWithGrade> submissionsWithGrades =
                      submissionSnapshot.data ?? [];

                  // Sort participants by lastname first, then by firstname as a secondary sort
                  participants.sort((a, b) {
                    int lastNameComparison = a.lastname.compareTo(b.lastname);
                    if (lastNameComparison != 0) {
                      return lastNameComparison; // If last names are different, return the result of this comparison
                    } else {
                      return a.firstname.compareTo(b
                          .firstname); // If last names are the same, compare by first name
                    }
                  });

                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: participants.map((participant) {
                        // Try to find a submission for the current participant
                        SubmissionWithGrade? submissionWithGrade =
                            submissionsWithGrades
                                .where((sub) =>
                                    sub.submission.userid == participant.id)
                                .firstOrNull;

                        return SizedBox(
                          width: MediaQuery.of(context).size.width < 450
                              ? double.infinity
                              : 450,
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  participant.fullname
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(participant
                                  .fullname), // Display the full name
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (submissionWithGrade != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Grade Status: ${submissionWithGrade.submission.gradingStatus}'),
                                        Text(
                                            'Status: ${submissionWithGrade.submission.status}'),
                                        Text(
                                            'Submitted on: ${submissionWithGrade.submission.submissionTime.toLocal()}'),
                                        Text(
                                            'Grade: ${submissionWithGrade.grade != null ? submissionWithGrade.grade!.grade.toString() : "Not graded yet"}'),
                                        SizedBox(height: 4),
                                        Text(
                                          'Content: ${submissionWithGrade.submission.onlineText.isNotEmpty ? "Available" : "No content provided."}',
                                          style: TextStyle(
                                            fontStyle: submissionWithGrade
                                                    .submission
                                                    .onlineText
                                                    .isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Comments: ${submissionWithGrade.submission.comments.isNotEmpty ? "Available" : "No comments."}',
                                          style: TextStyle(
                                            fontStyle: submissionWithGrade
                                                    .submission
                                                    .comments
                                                    .isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 52),
                                        Text('No Submission',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error)),
                                        SizedBox(height: 84),
                                      ],
                                    ),
                                  SizedBox(
                                      height:
                                          8), // Add spacing before the button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (submissionWithGrade != null &&
                                          submissionWithGrade
                                                  .submission.gradingStatus ==
                                              'notgraded')
                                        ElevatedButton(
                                          onPressed: () async {
                                              try
                                              {
                                                // TODO: Add Loading indicator
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                // Fetch submission and context ID
                                                var submissionText =submissionWithGrade.submission.onlineText;
                                                int? contextId = await MoodleApiSingleton().getContextId(widget.assignmentId, widget.courseId);

                                                // Fetch rubric
                                                var fetchedRubric;
                                                if (contextId != null) 
                                                {
                                                  fetchedRubric = await MoodleApiSingleton().getRubric(widget.assignmentId.toString());
                                                  if (fetchedRubric == null) 
                                                  {
                                                    print('Failed to fetch rubric.');
                                                    return;
                                                  }
                                                  // Ensure the rubric is serialized to JSON format
                                                  fetchedRubric = jsonEncode(fetchedRubric?.toJson() ?? {});
                                                }
                                                
                                                // Create prompt to send to LLM for grading
                                                String queryPrompt = '''
                                                  I am building a program that generates essay rubric assignments that teachers can distribute to students
                                                  who can then submit their responses to be graded. Here is an example format of a rubric roughly:
                                                  [
                                                      {
                                                          "id": 82,
                                                          "rubric_criteria": [
                                                              {
                                                                  "id": 52,
                                                                  "description": "Content",
                                                                  "levels": [
                                                                      {
                                                                          "id": 157,
                                                                          "score": 1,
                                                                          "definition": "Poor"
                                                                      },
                                                                      {
                                                                          "id": 156,
                                                                          "score": 3,
                                                                          "definition": "Good"
                                                                      },
                                                                      {
                                                                          "id": 155,
                                                                          "score": 5,
                                                                          "definition": "Excellent"
                                                                      }
                                                                  ]
                                                              },
                                                              {
                                                                  "id": 53,
                                                                  "description": "Clarity",
                                                                  "levels": [
                                                                      {
                                                                          "id": 160,
                                                                          "score": 1,
                                                                          "definition": "Unclear"
                                                                      },
                                                                      {
                                                                          "id": 159,
                                                                          "score": 3,
                                                                          "definition": "Somewhat Clear"
                                                                      },
                                                                      {
                                                                          "id": 158,
                                                                          "score": 5,
                                                                          "definition": "Very Clear"
                                                                      }
                                                                  ]
                                                              }
                                                          ]
                                                      }
                                                  ]

                                                  I have the following generated essay rubric:
                                                  Rubric: $fetchedRubric

                                                  Grade the following submission based on that rubric: 
                                                  Submission: $submissionText 

                                                  You must reply with a representation of the rubric in JSON format that matches this example format, 
                                                  obviously put your generated scores in and be specific with the remarks on the scoring and give specific examples from the 
                                                  submitted assignment that were either good or bad depending on the score given. Also cut out anything that is not
                                                  the json response. No extraneous comments outside that: 
                                                  {
                                                      "criterionid": 52,
                                                      "criterion_description": "Content",
                                                      "levelid": 157,
                                                      "level_description": "Poor",
                                                      "score": 1,
                                                      "remark": "Done with mirrors."
                                                  },
                                                  {
                                                      "criterionid": 53,
                                                      "criterion_description": "Clarity",
                                                      "levelid": 160,
                                                      "level_description": "Unclear",
                                                      "score": 1,
                                                      "remark": "Rocks."
                                                  }
                                                ''';

                                                // Initialize the LLM API with your Perplexity API key
                                                String apiKey = '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';
                                                final llmApi = LlmApi(apiKey);

                                                // Retrieve response in the format of a graded JSON rubric
                                                String gradedResponse = await llmApi.postToLlm(queryPrompt);
                                                gradedResponse = gradedResponse.replaceAll('```json', '').replaceAll('```', '').trim();
                                                print("debug line");
                                              }
                                              catch (e)
                                              {
                                                print('An error occurred: $e');
                                              }
                                              finally 
                                              {
                                                // Hide loading indicator
                                                setState(() {
                                                  isLoading = false; // Update your loading state
                                                });
                                              }
                                          },
                                          child: Text('Grade'),
                                        ),
                                      SizedBox(width: 8),
                                      if (submissionWithGrade != null)
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SubmissionDetail(
                                                  participant: participant,
                                                  submission:
                                                      submissionWithGrade!
                                                          .submission,
                                                  courseId: widget.courseId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('View Details'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
