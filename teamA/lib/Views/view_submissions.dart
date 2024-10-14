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
      ),
      body: FutureBuilder<List<SubmissionWithGrade>>(
        future: futureSubmissionsWithGrades,
        builder: (BuildContext context,
            AsyncSnapshot<List<SubmissionWithGrade>> submissionSnapshot) {
          if (submissionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (submissionSnapshot.hasError) {
            return Center(child: Text('Error: ${submissionSnapshot.error}'));
          } else if (!submissionSnapshot.hasData ||
              submissionSnapshot.data!.isEmpty) {
            return Center(child: Text('No submissions found.'));
          } else {
            return FutureBuilder<List<Participant>>(
              future: futureParticipants,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Participant>> participantSnapshot) {
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
                  List<SubmissionWithGrade> submissionsWithGrades =
                      submissionSnapshot.data!;
                  List<Participant> participants = participantSnapshot.data!;

                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: submissionsWithGrades.map((submissionWithGrade) {
                        Submission submission = submissionWithGrade.submission;
                        Grade? grade = submissionWithGrade.grade;

                        // Find the corresponding participant for this submission
                        Participant? participant = participants.firstWhere(
                          (p) => p.id == submission.userid,
                          orElse: () => Participant(
                              id: submission.userid,
                              username: 'Unknown',
                              fullname: 'Unknown',
                              roles: []),
                        );

                        return SizedBox(
                          width: MediaQuery.of(context).size.width < 450 ? double.infinity : 450,
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primaryContainer,
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
                              title: Text(
                                  participant.fullname), // Display the full name
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Grade Status: ${submission.gradingStatus}'),
                                  Text('Status: ${submission.status}'),
                                  Text(
                                      'Submitted on: ${submission.submissionTime.toLocal()}'),
                                  Text(
                                    'Grade: ${grade != null ? grade.grade.toString() : "Not graded yet"}',
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Content: ${submission.onlineText.isNotEmpty ? "Available" : "No content provided."}',
                                    style: TextStyle(
                                      fontStyle: submission.onlineText.isNotEmpty
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Comments: ${submission.comments.isNotEmpty ? "Available" : "No comments."}',
                                    style: TextStyle(
                                      fontStyle: submission.comments.isNotEmpty
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                  // SizedBox(height: 8), // Add spacing before the button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (submission.gradingStatus ==
                                          'notgraded')
                                        ElevatedButton(
                                          onPressed: () async {
                                            var submissionText =
                                                submission.onlineText;
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
                                      // SizedBox(width: 8),
                                      // if (submission.gradingStatus == 'graded')
                                      //   ElevatedButton(
                                      //     onPressed: () async {
                                      //       var tempvar = await api
                                      //           .getSubmissionStatus(
                                      //               widget.assignmentId,
                                      //               participant.id);
                                      //     },
                                      //     child: Text(
                                      //         'Grade'),
                                      //   ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SubmissionDetail(
                                                submission: submission,
                                                assignmentId:
                                                    widget.assignmentId,
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
