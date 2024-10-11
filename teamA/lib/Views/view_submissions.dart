// lib/submission_list.dart

import 'package:flutter/material.dart';
import '../Api/moodle_api_singleton.dart';
import '../Controller/beans.dart';
import 'view_submission_detail.dart';

class SubmissionList extends StatefulWidget {
  // final MoodleApiSingleton moodleService;
  final int assignmentId;
  final String courseId;

  SubmissionList({
    // required this.moodleService,
    required this.assignmentId,
    required this.courseId,
  });

  @override
  SubmissionListState createState() => SubmissionListState();
}

class SubmissionListState extends State<SubmissionList> {
  MoodleApiSingleton api = MoodleApiSingleton();
  late Future<List<Submission>> futureSubmissions = api.getAssignmentSubmissions(widget.assignmentId);
  static String myAssignmentId = myAssignmentId;
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Submission>>(
      future: futureSubmissions,
      builder:
          (BuildContext context, AsyncSnapshot<List<Submission>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If the future encountered an error, display it.
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If the data is empty, show a message.
          return Center(child: Text('No submissions found.'));
        } else {
          // If the data is available, display it in a list.
          List<Submission> submissions = snapshot.data!;
          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              Submission submission = submissions[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('User ID: ${submission.userid}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${submission.status}'),
                      Text(
                          'Submitted on: ${submission.submissionTime.toLocal()}'),
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
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    // Navigate to the SubmissionDetail screen with rubric data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionDetail(
                          submission: submission, assignmentId: widget.assignmentId, courseId:  widget.courseId
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
