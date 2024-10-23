import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:learninglens_app/Controller/custom_appbar.dart';
import '../Api/moodle_api_singleton.dart';
import '../Controller/beans.dart';
import 'view_submission_detail.dart';
import '../Api/llm_api.dart';
import 'dart:convert';

class SubmissionList extends StatefulWidget {
  final int assignmentId;
  final String courseId;
  static var apiKey = dotenv.env['perplexity_apikey'] ?? '';
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
    _fetchData();
  }

  //needed to refresh the submissions if a grade gets updated on the detail page
  void _fetchData() {
    setState(() {
      futureSubmissionsWithGrades =
          api.getSubmissionsWithGrades(widget.assignmentId);
      futureParticipants = api.getCourseParticipants(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Submissions', userprofileurl: MoodleApiSingleton().moodleProfileImage ?? ''),
      body: Stack(
        children: [
          FutureBuilder<List<Participant>>(
            future: futureParticipants,
            builder: (BuildContext context,
                AsyncSnapshot<List<Participant>> participantSnapshot) {
              print("Rebuilding FutureBuilder with new data..."); // Debug log
              if (participantSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (participantSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${participantSnapshot.error}'));
              } else if (!participantSnapshot.hasData ||
                  participantSnapshot.data!.isEmpty) {
                return Center(child: Text('No participants found.'));
              } else {
                return FutureBuilder<List<SubmissionWithGrade>>(
                  future: futureSubmissionsWithGrades,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<SubmissionWithGrade>>
                          submissionSnapshot) {
                    if (submissionSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (submissionSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${submissionSnapshot.error}'));
                    } else {
                      List<Participant> participants =
                          participantSnapshot.data!;
                      List<SubmissionWithGrade> submissionsWithGrades =
                          submissionSnapshot.data ?? [];

                      // Sort participants by lastname first, then by firstname as a secondary sort
                      participants.sort((a, b) {
                        int lastNameComparison =
                            a.lastname.compareTo(b.lastname);
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer, // Card background color
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Card(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  elevation: 0, // Optional: Remove card shadow if needed
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      child: Text(
                                        participant.fullname
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                    title: Text(participant.fullname),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error)),
                                              SizedBox(height: 84),
                                            ],
                                          ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (submissionWithGrade != null &&
                                                submissionWithGrade.submission
                                                        .gradingStatus ==
                                                    'notgraded')
                                              isLoading
                                                  ? CircularProgressIndicator()
                                                  : ElevatedButton(
                                                      onPressed: () async {
                                                        try {
                                                          setState(() {
                                                            isLoading = true;
                                                          });
                                                          var submissionText =
                                                              submissionWithGrade
                                                                  .submission
                                                                  .onlineText;
                                                          int? contextId =
                                                              await MoodleApiSingleton()
                                                                  .getContextId(
                                                                      widget
                                                                          .assignmentId,
                                                                      widget
                                                                          .courseId);

                                                          var fetchedRubric;
                                                          if (contextId !=
                                                              null) {
                                                            fetchedRubric =
                                                                await MoodleApiSingleton()
                                                                    .getRubric(widget
                                                                        .assignmentId
                                                                        .toString());
                                                            if (fetchedRubric ==
                                                                null) {
                                                              print(
                                                                  'Failed to fetch rubric.');
                                                              return;
                                                            }
                                                            fetchedRubric = jsonEncode(
                                                                fetchedRubric
                                                                        ?.toJson() ??
                                                                    {});
                                                          }

                                                          String queryPrompt =
                                                              '''
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
                                                  submitted assignment that were either good or bad depending on the score given.
                                                ''';

                                                          final perplexityApiKey =
                                                              dotenv.env[
                                                                  'perplexity_apikey'] ??
                                                                  '';
                                                          final llmApi = LlmApi(
                                                              perplexityApiKey);

                                                          String gradedResponse =
                                                              await llmApi.postToLlm(
                                                                  queryPrompt);
                                                          gradedResponse =
                                                              gradedResponse
                                                                  .replaceAll(
                                                                      '```json',
                                                                      '')
                                                                  .replaceAll(
                                                                      '```',
                                                                      '')
                                                                  .trim();
                                                          var results =
                                                              await MoodleApiSingleton()
                                                                  .setRubricGrades(
                                                                      widget
                                                                          .assignmentId,
                                                                      participant
                                                                          .id,
                                                                      gradedResponse);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SubmissionDetail(
                                                                participant:
                                                                    participant,
                                                                submission:
                                                                    submissionWithGrade
                                                                        .submission,
                                                                courseId: widget
                                                                    .courseId,
                                                              ),
                                                            ),
                                                          );
                                                          print(
                                                              'Results: $results');
                                                        } catch (e) {
                                                          print(
                                                              'An error occurred: $e');
                                                        } finally {
                                                          setState(() {
                                                            isLoading =
                                                                false;
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
                                                        participant:
                                                            participant,
                                                        submission:
                                                            submissionWithGrade
                                                                .submission,
                                                        courseId:
                                                            widget.courseId,
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
        ],
      ),
    );
  }
}
