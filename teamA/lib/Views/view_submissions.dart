/*
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
  late Future<List<Participant>> futureParticipants = api.getCourseParticipants(widget.courseId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Submission>>(
      future: futureSubmissions,
      builder:
          (BuildContext context, AsyncSnapshot<List<Submission>> submissionSnapshot) {
        if (submissionSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (submissionSnapshot.hasError) {
          return Center(child: Text('Error: ${submissionSnapshot.error}'));
        } else if (!submissionSnapshot.hasData || submissionSnapshot.data!.isEmpty) {
          return Center(child: Text('No submissions found.'));
        } else {
          return FutureBuilder<List<Participant>>(
            future: futureParticipants,
            builder: (BuildContext context, AsyncSnapshot<List<Participant>> participantSnapshot) {
              if (participantSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (participantSnapshot.hasError) {
                return Center(child: Text('Error: ${participantSnapshot.error}'));
              } else if (!participantSnapshot.hasData || participantSnapshot.data!.isEmpty) {
                return Center(child: Text('No participants found.'));
              } else {
                List<Submission> submissions = submissionSnapshot.data!;
                List<Participant> participants = participantSnapshot.data!;

return GridView.builder(
  itemCount: submissions.length,
  itemBuilder: (context, index) {
    Submission submission = submissions[index];

    // Find the corresponding participant for this submission
    Participant? participant = participants.firstWhere(
      (p) => p.id == submission.userid,
      orElse: () => Participant(id: submission.userid, username: 'Unknown', fullname: 'Unknown', roles: []),
    );

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('Name: ${participant.fullname}'), // Display the full name
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grade Status: ${submission.gradingStatus}'),
            Text('Status: ${submission.status}'),
            Text('Submitted on: ${submission.submissionTime.toLocal()}'),
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
            SizedBox(height: 8), // Add spacing before the button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (submission.gradingStatus == 'notgraded')
                  ElevatedButton(
                    onPressed: () {
                      // Logic to open grading page or perform grading action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmissionDetail(
                            submission: submission,
                            assignmentId: widget.assignmentId,
                            courseId: widget.courseId,
                          ),
                        ),
                      );
                    },
                    child: Text('Grade'), // Button label
                  ),
                SizedBox(width: 8), // Space between buttons
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the SubmissionDetail screen with rubric data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionDetail(
                          submission: submission,
                          assignmentId: widget.assignmentId,
                          courseId: widget.courseId,
                        ),
                      ),
                    );
                  },
                  child: Text('View Details'), // Button label
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  },
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // Adjust the number of columns as needed
    mainAxisSpacing: 10.0,
    crossAxisSpacing: 10.0,
    childAspectRatio: 2.0,
  ),
);


              }
            },
          );
        }
      },
    );
  }
}
*/

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

  // Updated to fetch submissions with grades
  late Future<List<SubmissionWithGrade>> futureSubmissionsWithGrades = api.getSubmissionsWithGrades(widget.assignmentId);
  late Future<List<Participant>> futureParticipants = api.getCourseParticipants(widget.courseId);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubmissionWithGrade>>(
      future: futureSubmissionsWithGrades,
      builder: (BuildContext context, AsyncSnapshot<List<SubmissionWithGrade>> submissionSnapshot) {
        if (submissionSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (submissionSnapshot.hasError) {
          return Center(child: Text('Error: ${submissionSnapshot.error}'));
        } else if (!submissionSnapshot.hasData || submissionSnapshot.data!.isEmpty) {
          return Center(child: Text('No submissions found.'));
        } else {
          return FutureBuilder<List<Participant>>(
            future: futureParticipants,
            builder: (BuildContext context, AsyncSnapshot<List<Participant>> participantSnapshot) {
              if (participantSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (participantSnapshot.hasError) {
                return Center(child: Text('Error: ${participantSnapshot.error}'));
              } else if (!participantSnapshot.hasData || participantSnapshot.data!.isEmpty) {
                return Center(child: Text('No participants found.'));
              } else {
                List<SubmissionWithGrade> submissionsWithGrades = submissionSnapshot.data!;
                List<Participant> participants = participantSnapshot.data!;

                return GridView.builder(
                  itemCount: submissionsWithGrades.length,
                  itemBuilder: (context, index) {
                    Submission submission = submissionsWithGrades[index].submission;
                    Grade? grade = submissionsWithGrades[index].grade;

                    // Find the corresponding participant for this submission
                    Participant? participant = participants.firstWhere(
                      (p) => p.id == submission.userid,
                      orElse: () => Participant(id: submission.userid, username: 'Unknown', fullname: 'Unknown', roles: []),
                    );

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Name: ${participant.fullname}'), // Display the full name
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grade Status: ${submission.gradingStatus}'),
                            Text('Status: ${submission.status}'),
                            Text('Submitted on: ${submission.submissionTime.toLocal()}'),
                            Text(
                              'Grade: ${grade != null ? grade.grade.toString() : "Not graded yet"}', // Display the grade
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Content: ${submission.onlineText.isNotEmpty ? "Available" : "No content provided."}',
                              style: TextStyle(
                                fontStyle: submission.onlineText.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Comments: ${submission.comments.isNotEmpty ? "Available" : "No comments."}',
                              style: TextStyle(
                                fontStyle: submission.comments.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 8), // Add spacing before the button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (submission.gradingStatus == 'notgraded')
                                  ElevatedButton(
                                    onPressed: () {
                                      // Logic to open grading page or perform grading action
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SubmissionDetail(
                                            submission: submission,
                                            assignmentId: widget.assignmentId,
                                            courseId: widget.courseId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Grade'), // Button label
                                  ),
                                SizedBox(width: 8), // Space between buttons
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to the SubmissionDetail screen with rubric data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubmissionDetail(
                                          submission: submission,
                                          assignmentId: widget.assignmentId,
                                          courseId: widget.courseId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('View Details'), // Button label
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Adjust the number of columns as needed
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 2.0,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
