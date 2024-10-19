import 'package:flutter/material.dart';
import '../Api/moodle_api_singleton.dart';
import '../Controller/beans.dart';
import 'view_submission_detail.dart';

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
                                            // Fetch submission and rubric for grading
                                            var submissionText =
                                                submissionWithGrade
                                                    .submission.onlineText;
                                            int? contextId =
                                                await MoodleApiSingleton()
                                                    .getContextId(
                                                        widget.assignmentId,
                                                        widget.courseId);
                                            if (contextId != null) {
                                              var fetchedRubric =
                                                  await MoodleApiSingleton()
                                                      .getRubric(widget
                                                          .assignmentId
                                                          .toString());
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
