import 'package:flutter/material.dart';

import '../../api/moodle/moodle_api_singleton.dart';
import 'assignment_submissions.dart';
import 'beans.dart';

class FirstPage extends StatelessWidget {
  Future<List<Submission>> getParticipantSubmissions() async {
    var submissions = await MoodleApiSingleton().getAssignmentSubmissions(55);
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
        title: Text('First Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            getParticipantSubmissions().then((var results) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AssignmentSubmissionsPage(55, "My Assignment", results),
                ),
              );
            });
          },
          child: Text('Go to Second Page'),
        ),
      ),
    );
  }
}
